from firebase_functions import firestore_fn, https_fn
from firebase_admin import initialize_app, firestore
import google.cloud.firestore

# Initalize!
app = initialize_app()

@https_fn.on_call()
def testFunction(req: https_fn.CallableRequest) -> any:

    # Query Firestore for the list of post documents sorted by most to least recent!
    orderedPosts = firestore.client().collection("posts").order_by("timePosted", direction = firestore.Query.DESCENDING).limit(3).stream()

    # Loop through each document and decide if it is close enough to the user!
    acceptedPosts = ["test string"]
    numPosts = 0
    for eachPost in orderedPosts:
        acceptedPosts += str(eachPost.to_dict()["text"])
        numPosts += 1

    # Return the posts to the user to be displayed!
    # ??????

    return {
        "message" : "lat " + req.data["latitude"] + ", long " + req.data["longitude"],
        "posts" : acceptedPosts,
        "numPosts" : str(numPosts)
    }