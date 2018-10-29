package metadatastore

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
    "path/filepath"
    "path"

	// utility that should go away
	"net/http/httputil"
)

func HandleLinkSerialization(w http.ResponseWriter,
	r *http.Request) {
	if r.Method != "POST" {
		http.NotFound(w, r)
		return
	}
	dump, err := httputil.DumpRequest(r, true)

	if err != nil {
		fmt.Printf("proper error handling is in order here\n")
	}
	// Should handle by returning a 200 ok or so
	fmt.Fprintf(w, "%q\n", dump)
	//fmt.Printf("%q\n", dump)

	linkName, namespace := parseURI(r.URL)
	body, _ := ioutil.ReadAll(r.Body)
	serializeLink(linkName, namespace, body)
}

func parseURI (location *url.URL) (string, string) {

	linkName := ""
	namespace := ""
    base := "/links"

	requestUri := location.RequestURI()
    normalizedPath, err := filepath.Rel(base, requestUri)
    if err != nil {
        // FIXME: we should be floating errors upwards here...
        panic(fmt.Sprintf("The couldn't compute the base properly: %v\n", err))
    }

    namespace, linkName = path.Split(normalizedPath)

// I completely misunderstood this function, but I want to avoid infinite namespaces. FIXME
////fields := filepath.SplitList(namespace)
////if len(fields) != 1 {
////    // FIXME: we should be floating errors upwards here...
////    panic(fmt.Sprintf("this namespace seems to be wrong: %v", len(fields)))
////}

	return linkName, namespace

}

func serializeLink(link string, namespace string, data []byte) {

	err := os.MkdirAll(namespace, 0755)
	if err != nil {
		fmt.Printf("couldn't create namespace dir! %v\n", err)
	}

	err = ioutil.WriteFile(fmt.Sprintf("%s/%s", namespace, link), data, 0644)
	if err != nil {
		fmt.Printf("Error writing to file: %v\n", err)
	}
}
