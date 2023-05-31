from firebase_functions import firestore_fn, https_fn
from firebase_admin import initialize_app, firestore
import google.cloud.firestore

# Initalize!
app = initialize_app()

@https_fn.on_call()
def testFunction(req: https_fn.CallableRequest) -> any:

    # Query Firestore for the list of post documents sorted by most to least recent!
    # ??????

    # Loop through each document and decide if it is close enough to the user!
    # ??????

    # Return the posts to the user to be displayed!
    # ??????

    return {
        "message" : "lat " + req.data["latitude"] + ", long " + req.data["longitude"],
        "number" : "5"
    }