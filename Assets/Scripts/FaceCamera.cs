using System.Collections;
using System.Collections.Generic;
using UnityEngine;
/// <summary>
/// Basically a billboard sprite script
/// </summary>
public class FaceCamera : MonoBehaviour {
	void Update () {
        //Use the camera's forward direction to determine the sprite's
        this.transform.forward = Camera.main.transform.forward;
	}
}
