import UIKit
import SceneKit
import ARKit

class MeasureViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self

        sceneView.showsStatistics = true
        sceneView.debugOptions = [.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            
            dotNodes = [SCNNode]()
        }
        
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = results.first {
                addDot(at: hitResult)
            }
        }
    }
    
    func addDot(at hitResult: ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(
            x: hitResult.worldTransform.columns.3.x,
            y: hitResult.worldTransform.columns.3.y,
            z: hitResult.worldTransform.columns.3.z
        )
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    func calculate() {
        let start = dotNodes[0]
        let end = dotNodes[1]

        let distX = end.position.x - start.position.x
        let distY = end.position.y - start.position.y
        let distZ = end.position.z - start.position.z

        let centerX = end.position.x + start.position.x
        let centerY = end.position.y + start.position.y
        let centerZ = end.position.z + start.position.z
        
        let distance = sqrt(pow(distX, 2) + pow(distY, 2) + pow(distZ, 2))
        let centerPosition = SCNVector3(x: centerX/2, y: centerY/2, z: centerZ/2)
        updateText(text: String(format: "%.3f", abs(distance)), atPosition: centerPosition)
    }
    
    func updateText(text: String, atPosition position: SCNVector3) {
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode = SCNNode(geometry: textGeometry)
        let textNodeWidth = (textGeometry.boundingBox.max.x - textGeometry.boundingBox.min.x) / 100
        
        textNode.position = SCNVector3(
            position.x - textNodeWidth / 2,
            position.y + 0.01,
            position.z - 0.01
        )
        
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        if let camera = sceneView.pointOfView {
            textNode.orientation = camera.orientation
        }
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    @IBAction func clearAll(_ sender: UIBarButtonItem) {
        
        textNode.removeFromParentNode()
        
        for dot in dotNodes {
            dot.removeFromParentNode()
        }
        
    }
    
}
