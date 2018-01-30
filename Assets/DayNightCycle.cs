using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DayNightCycle : MonoBehaviour {

    public float rotationSpeed;

	void Update () {
        this.transform.Rotate(0f, rotationSpeed, 0f);
	}
}