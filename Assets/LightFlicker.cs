using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightFlicker : MonoBehaviour {

    [Range(0f,1f)]
    public float minFlickerIntensity;
    [Range(1f, 2f)]
    public float maxFlickerIntensity;
    [Range(0f, 1f)]
    public float randomScaleMin;
    [Range(1f, 2f)]
    public float randomScaleMax;
    [Range(0f, 1f)]
    public float flickerTime;
    public Color minColor, maxColor;
    [Range(0f,1f)]
    public float colorLerpSpeed;
    protected float waitingTime;
    protected float randomScale;
    protected float colorLerp;
    protected Light light;
    protected Color targetColor;

    private void Start()
    {
        light = this.GetComponent<Light>();
        waitingTime = 0f;
    }

    private void Update()
    {
        waitingTime += Time.deltaTime;
        if (waitingTime > flickerTime)
        {
            Flicker();
            waitingTime = 0f;
        }
        light.color = Color.Lerp(light.color, targetColor, colorLerpSpeed);
    }

    protected void Flicker()
    {
        light.intensity = (Random.Range(minFlickerIntensity, maxFlickerIntensity));
        randomScale = Random.Range(randomScaleMin, randomScaleMax);
        targetColor = Color.Lerp(minColor, maxColor, Random.Range(0f, 1f));
        //light.color = new Color(col.r, col.g, col.b, 1f);
    }
}
