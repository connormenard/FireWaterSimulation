using System.Collections;
using System.Collections.Generic;
using UnityEngine;
/// <summary>
/// Basic script, just animates a buncha jpegs
/// </summary>
public class AnimateImages : MonoBehaviour {
    
    //Individual frames
    public Texture2D[] images;
    //Speed at which to cycle through them (higher=faster)
    public float speed;

    void Update()
    {
        //Get the index based on overall time
        float frame = Time.fixedTime * speed;
        //If we go past the limit then loop back
        frame = frame % images.Length;
        //Get the renderer and update it accordingly
        this.GetComponent<Renderer>().material.mainTexture = images[(int)frame];
    }
}
