using UnityEngine;
using System.Collections;

public class TransformResetter : MonoBehaviour
{

    Vector3 m_initialPosition;
    Quaternion m_initialRotation;
    Vector3 m_initialScale;

    void Awake()
    {
        SaveTransform();
    }

    private void SaveTransform()
    {
        m_initialPosition = transform.position;
        m_initialRotation = transform.rotation;
        m_initialScale = transform.localScale;
    }


    void OnEnable()
    {
        RestoreTransform();
    }

    private void RestoreTransform()
    {
        transform.position = m_initialPosition;
        transform.rotation = m_initialRotation;
        transform.localScale = m_initialScale;
    }
}
