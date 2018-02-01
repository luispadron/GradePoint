//
//  GameScene.swift
//  GradePoint
//
//  Created by Luis Padron on 1/30/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import SpriteKit

class GameScence: SKScene {
    // MARK: Members

    private var hasGameStarted = false
    private var isDead = false

    private let flapSound = SKAction.playSoundFileNamed("BirdFlap.wav", waitForCompletion: false)
    private let rewardSound = SKAction.playSoundFileNamed("RewardSound.wav", waitForCompletion: false)
    private let thudSound = SKAction.playSoundFileNamed("ThudSound.wav", waitForCompletion: true)

    /// The controller which controlls this scene
    public weak var gameController: UIViewController? = nil

    private var score: Int = 0 {
        didSet {
            // Update score label
            self.scoreLabel.text = "\(self.score)"
            // Update highscore
            self.saveHighScore()
            let hscore = UserDefaults.standard.integer(forKey: kUserDefaultGradeBirdHighScore)
            self.highScoreLabel.text = "High Score: \(hscore)"
        }
    }

    private lazy var moveAndRemove: SKAction = {
        let distance = self.frame.width + self.wallPair.frame.width
        return SKAction.sequence([SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(0.008 * distance)),
                                  SKAction.removeFromParent()])
    }()

    private var wallPair = SKNode()

    // MARK: Bird atlas

    let birdAtlas = SKTextureAtlas(named: "bird")

    /// The textures for the bird sprite
    private lazy var birdSprites: [SKTexture] = {
        return [birdAtlas.textureNamed("bookBird1"),
                birdAtlas.textureNamed("bookBird2"),
                birdAtlas.textureNamed("bookBird3"),
                birdAtlas.textureNamed("bookBird4")]
    }()

    private var repeatBirdAnimationAction: SKAction?

    // MARK: Scene life cycle

    override func didMove(to view: SKView) {
        self.createScence()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.hasGameStarted {
            self.hasGameStarted = true
            self.bird.physicsBody?.affectedByGravity = true
            self.addChild(self.pauseButton)
            self.logo.run(SKAction.scale(to: 0.5, duration: 0.3), completion: {
                self.logo.removeFromParent()
            })
            self.playLabel.removeFromParent()
            self.bird.run(self.repeatBirdAnimationAction ?? SKAction())

            let spawn = SKAction.run({
                self.createWallPair()
                self.addChild(self.wallPair)
            })
            let delay = SKAction.wait(forDuration: 1.5)
            let spawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(spawnDelay)
            self.run(spawnDelayForever)

            self.bird.physicsBody?.velocity = .zero
            self.bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
            self.run(self.flapSound)
        } else {
            if !isDead {
                self.run(self.flapSound)
                self.bird.physicsBody?.velocity = .zero
                self.bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
            }
        }

        // Handle touches to restart/pause buttons
        for touch in touches {
            if self.isDead && self.restartButton.contains(touch.location(in: self)) {
                self.saveHighScore()
                self.restartScene()
            } else if self.pauseButton.contains(touch.location(in: self)) {
                self.isPaused = !self.isPaused
                self.pauseButton.texture = self.isPaused ? SKTexture(imageNamed: "PauseButtonIcon") :
                                                        SKTexture(imageNamed: "PlayButtonIcon")
            } else if self.exitButton.contains(touch.location(in: self)) {
                self.saveHighScore()
                self.gameController?.dismiss(animated: true, completion: nil)
            }
        }
    }

    override func update(_ currentTime: TimeInterval) {
        if !hasGameStarted && !isDead {
            // Keep background scrolling
            self.enumerateChildNodes(withName: "background", using: { node, error in
                guard let bg = node as? SKSpriteNode else { return }
                bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                if bg.position.x <= -bg.size.width {
                    bg.position = CGPoint(x: bg.position.x + bg.size.width * 2, y: bg.position.y)
                }
            })
        }
    }

    // MARK: Helpers

    /// Creates the main scene
    private func createScence() {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = CollisionBitMask.groundCategory
        self.physicsBody?.collisionBitMask = CollisionBitMask.birdCategory
        self.physicsBody?.contactTestBitMask = CollisionBitMask.birdCategory
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false

        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)

        self.createBackground()

        self.addChild(self.bird)
        let animateBird = SKAction.animate(with: self.birdSprites, timePerFrame: 0.1)
        self.repeatBirdAnimationAction = SKAction.repeatForever(animateBird)

        // Add sprites
        self.addChild(self.scoreLabel)
        self.addChild(self.highScoreLabel)
        self.addChild(self.playLabel)
        self.addChild(self.logo)
        self.addChild(self.exitButton)
    }

    /// Restarts the scence
    private func restartScene() {
        self.removeAllChildren()
        self.removeAllActions()
        self.isDead = false
        self.hasGameStarted = false
        self.score = 0
        self.isPaused = false
        self.bird.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        self.bird.zRotation = 0
        self.createScence()
    }

    /// Saves the current score if higher than highscore
    private func saveHighScore() {
        let hscore = UserDefaults.standard.integer(forKey: kUserDefaultGradeBirdHighScore)
        UserDefaults.standard.set(hscore > self.score ? hscore : self.score, forKey: kUserDefaultGradeBirdHighScore)
    }

    /// Creates the background sprites
    private func createBackground() {
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "GradeBirdBackground")
            background.anchorPoint = CGPoint(x: 0, y: 0)
            background.position = CGPoint(x: CGFloat(i) * self.frame.width, y: 0)
            background.name = "background"
            background.size = self.view?.bounds.size ?? .zero
            self.addChild(background)
        }
    }

    /// Creates a random number within given range
    private func randomNumber(min: CGFloat, max: CGFloat) -> CGFloat {
        let rand = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return rand * (max - min) + min
    }

    // MARK: Sprites

    /// The score label which displays current score
    private lazy var scoreLabel: SKLabelNode = {
        let label = SKLabelNode()
        label.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.8)
        label.text = "\(score)"
        label.zPosition = 5
        label.fontSize = 50
        label.fontName = "HelveticaNeue-Bold"

        let scoreBg = SKShapeNode()
        scoreBg.position = CGPoint(x: 0, y: 0)
        let rect = CGRect(x: -50, y: -30, width: 100, height: 100)
        scoreBg.path = CGPath(roundedRect: rect, cornerWidth: 50, cornerHeight: 50, transform: nil)
        let scoreBgColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
        scoreBg.strokeColor = .clear
        scoreBg.fillColor = scoreBgColor
        scoreBg.zPosition = -1

        label.addChild(scoreBg)

        return label
    }()

    /// The label which displays the users high score
    private lazy var highScoreLabel: SKLabelNode = {
        let label = SKLabelNode()
        label.position = CGPoint(x: self.frame.width - 80, y: self.frame.height - 50)
        let highestScore = UserDefaults.standard.integer(forKey: kUserDefaultGradeBirdHighScore)
        label.text = "Highest Score: \(highestScore)"
        label.zPosition = 5
        label.fontSize = 15
        label.fontName = "Helvetica-Bold"
        return label
    }()

    /// The play label which starts the game
    private lazy var playLabel: SKLabelNode = {
        let label = SKLabelNode()
        label.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 100)
        label.text = "Tap anywhere to play"
        label.fontColor = UIColor(red: 63/255, green: 79/255, blue: 145/255, alpha: 1.0)
        label.zPosition = 5
        label.fontSize = 20
        label.fontName = "HelveticaNeue"
        return label
    }()

    /// The exit button which exits the game
    private lazy var exitButton: SKSpriteNode = {
        let button = SKSpriteNode(imageNamed: "ExitButtonIcon")
        button.size = CGSize(width: 40, height: 40)
        button.position = CGPoint(x: 40, y: self.frame.height - 50)
        button.zPosition = 6
        button.setScale(0)
        button.run(SKAction.scale(to: 1.0, duration: 0.3))
        return button
    }()

    /// The restart button which restarts the game
    private lazy var restartButton: SKSpriteNode = {
        let button = SKSpriteNode(imageNamed: "RestartButtonIcon")
        button.size = CGSize(width: 100, height: 100)
        button.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        button.zPosition = 6
        button.setScale(0)
        button.run(SKAction.scale(to: 1.0, duration: 0.3))
        return button
    }()

    /// The button which pauses the game
    private lazy var pauseButton: SKSpriteNode = {
        let button = SKSpriteNode(imageNamed: "PauseButtonIcon")
        button.size = CGSize(width: 40, height: 40)
        button.position = CGPoint(x: self.frame.width - 40, y: 50)
        button.zPosition = 6
        return button
    }()

    /// The logo for the game
    private lazy var logo: SKSpriteNode = {
        let logo = SKSpriteNode(imageNamed: "GradeBirdLogo")
        logo.size = CGSize(width: 272, height: 65)
        logo.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 100)
        logo.setScale(0.5)
        logo.run(SKAction.scale(to: 1.0, duration: 0.3))
        return logo
    }()

    /// The bird the player playes as
    private lazy var bird: SKSpriteNode = {
        let bird = SKSpriteNode(texture: self.birdSprites.first)
        bird.size = CGSize(width: 50, height: 50)
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)

        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width / 2)
        bird.physicsBody?.linearDamping = 1.1
        bird.physicsBody?.restitution = 0
        bird.physicsBody?.categoryBitMask = CollisionBitMask.birdCategory
        bird.physicsBody?.collisionBitMask = CollisionBitMask.pillarCategory | CollisionBitMask.groundCategory
        bird.physicsBody?.contactTestBitMask = CollisionBitMask.pillarCategory | CollisionBitMask.groundCategory |
            CollisionBitMask.aPlusCategory
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.isDynamic = true
        return bird
    }()

    /// Creates a wall with given image name
    private func createWall(imageName: String, topWall: Bool) -> SKSpriteNode {
        let wall = SKSpriteNode(imageNamed: imageName)
        let yForWall = topWall ? self.frame.height / 2 + 420 : self.frame.height / 2 - 420
        wall.position = CGPoint(x: self.frame.width + 25, y: yForWall)
        wall.setScale(0.5)

        wall.physicsBody = SKPhysicsBody(rectangleOf: wall.size)
        wall.physicsBody?.categoryBitMask = CollisionBitMask.pillarCategory
        wall.physicsBody?.collisionBitMask = CollisionBitMask.birdCategory
        wall.physicsBody?.contactTestBitMask = CollisionBitMask.birdCategory
        wall.physicsBody?.affectedByGravity = false
        wall.physicsBody?.isDynamic = false

        return wall
    }

    private func createWallPair() {
        let aPlusNode = SKSpriteNode(imageNamed: "APlusImage")
        aPlusNode.size = CGSize(width: 40, height: 40)
        aPlusNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        aPlusNode.physicsBody = SKPhysicsBody(rectangleOf: aPlusNode.size)
        aPlusNode.physicsBody?.affectedByGravity = false
        aPlusNode.physicsBody?.isDynamic = false
        aPlusNode.physicsBody?.categoryBitMask = CollisionBitMask.aPlusCategory
        aPlusNode.physicsBody?.collisionBitMask = 0
        aPlusNode.physicsBody?.contactTestBitMask = CollisionBitMask.birdCategory

        let topWall = createWall(imageName: "PillarSprite", topWall: true)
        topWall.zRotation = CGFloat.pi

        let bottomWall = createWall(imageName: "PillarSprite", topWall: false)

        self.wallPair = SKNode()
        self.wallPair.name = "wallPair"
        self.wallPair.zPosition = 1

        self.wallPair.addChild(topWall)
        self.wallPair.addChild(bottomWall)

        let randomPosition = randomNumber(min: -200, max: 200)
        self.wallPair.position.y = self.wallPair.position.y + randomPosition

        self.wallPair.addChild(aPlusNode)

        self.wallPair.run(moveAndRemove)
    }
}

extension GameScence: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB

        let bcat = CollisionBitMask.birdCategory
        let pcat = CollisionBitMask.pillarCategory
        let gcat = CollisionBitMask.groundCategory
        let acat = CollisionBitMask.aPlusCategory

        if (firstBody.categoryBitMask == bcat || secondBody.categoryBitMask == bcat) &&
            (firstBody.categoryBitMask == pcat || secondBody.categoryBitMask == pcat) ||
            (firstBody.categoryBitMask == gcat || secondBody.categoryBitMask == gcat) {
            // Bird has hit pillar or ground
            self.enumerateChildNodes(withName: "wallPair", using: { node, error in
                node.speed = 0
                self.removeAllActions()
            })
            
            // Prepare scene for death
            if !self.isDead {
                self.isDead = true
                self.addChild(self.restartButton)
                self.pauseButton.removeFromParent()
                self.bird.removeAllActions()
                self.saveHighScore()
                self.run(self.thudSound)
            }
        } else if (firstBody.categoryBitMask == bcat || secondBody.categoryBitMask == bcat) &&
                    (firstBody.categoryBitMask == acat || secondBody.categoryBitMask == acat){
            // Bird collided with treat, add score
            self.score += 1
            self.run(self.rewardSound)
            let aPlusNode = firstBody.categoryBitMask == acat ? firstBody.node : secondBody.node
            aPlusNode?.removeFromParent()
        }
    }
}
