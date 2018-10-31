package webhook

import (
	"context"
	"fmt"
	"github.com/santiagotorres/kubectl-in-toto/pkg/in_toto"
	"github.com/slok/kubewebhook/pkg/log"
	"github.com/slok/kubewebhook/pkg/observability/metrics"
	"github.com/slok/kubewebhook/pkg/webhook"
	"github.com/slok/kubewebhook/pkg/webhook/validating"
	"k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// podValidator validates the definition against the Kubesec.io score.
type PodValidator struct {
	Logger log.Logger
}

func (d *PodValidator) Validate(_ context.Context, obj metav1.Object) (bool, validating.ValidatorResult, error) {
	kObj, ok := obj.(*v1.Pod)
	if !ok {
		return false, validating.ValidatorResult{Valid: true}, nil
	}

	kObj.TypeMeta = metav1.TypeMeta{
		Kind:       "Pod",
		APIVersion: "v1",
	}

	d.Logger.Infof("Validating containers in pod: %s", kObj.Name)

	var container v1.Container
	for i := range kObj.Spec.Containers {
		container = kObj.Spec.Containers[i]
		fmt.Printf("Validating %v\n", container.Image)
		result, err := in_toto.NewClient().ScanContainer(container.Image)
		if err != nil {
			d.Logger.Errorf("in-toto validation failed %v", err)
			return false, validating.ValidatorResult{Valid: true}, nil
		}
		if result.Retval != 0 {
			d.Logger.Errorf("in-toto validation failed %v", result.Error)
			return false, validating.ValidatorResult{Valid: true}, nil
		}
	}

	return true, validating.ValidatorResult{Valid: true}, nil
}

// NewPodWebhook returns a new deployment validating webhook.
func NewPodWebhook(minScore int, mrec metrics.Recorder, logger log.Logger) (webhook.Webhook, error) {

	// Create validators.
	val := &PodValidator{
		Logger: logger,
	}

	cfg := validating.WebhookConfig{
		Name: "in-toto-pod",
		Obj:  &v1.Pod{},
	}

	return validating.NewWebhook(cfg, val, mrec, logger)
}
