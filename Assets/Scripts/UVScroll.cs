using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UVScroll : MonoBehaviour {

    public float scrollSpeedX, scrollSpeedY;
    public bool u, v;
    protected float offsetX, offsetY;
    public string[] textures;

    void Update()
    {
        offsetX = Time.time * scrollSpeedX % 1;
        offsetY = Time.time * scrollSpeedY % 1;
        foreach (string s in textures)
            this.GetComponent<Renderer>().material.SetTextureOffset(s, new Vector2((u) ? offsetX : 0, (v) ? offsetY : 0));
    }
}
