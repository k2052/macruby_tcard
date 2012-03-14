class TCardView < NSView 
  attr_accessor :zPositionLabel, :angleXLabel, :angleYLabel, :layerForImage
  
  def awakeFromNib()
    whiteBackground =  CGColorCreateGenericRGB(1.0, 1.0, 1.0, 1.0)
    blackText       =  CGColorCreateGenericRGB(0.0, 0.0, 0.0, 0.6)
    self.layer      = CALayer.layer
    self.setWantsLayer(true)
    self.layer.layoutManager   = CAConstraintLayoutManager.layoutManager()
    self.layer.backgroundColor = whiteBackground
    self.layer.addSublayer(self.layerForImage())
    
    infoLayer = CATextLayer.layer
    infoLayer.string          = "Torcelly.com 2011"
    infoLayer.foregroundColor = blackText
    infoLayer.fontSize        = 10
    infoLayer.constraints = NSArray.arrayWithObjects(CAConstraint.constraintWithAttribute(KCAConstraintMaxX,
                                                        relativeTo:"superlayer", 
                                                         attribute:KCAConstraintMaxX,
                                                            offset:-10.0), 
                             CAConstraint.constraintWithAttribute(KCAConstraintMinY, 
                                                        relativeTo:"superlayer", 
                                                         attribute:KCAConstraintMinY,
                                                            offset:10.0),
                             nil)
      
    self.layer.addSublayer(infoLayer)
    
    CGColorRelease(whiteBackground)
    CGColorRelease(blackText)
    
    zPositionLabel.setStringValue "0.0"
    angleYLabel.setStringValue "0.0"
    angleXLabel.setStringValue "0.0"   
  end 
  
  def layerForImage()
    image = NSImage.alloc.initWithContentsOfFile(NSBundle.mainBundle.pathForResource("Photo", ofType:"jpg"))
    aLayerRect = NSMakeRect(0.0, 0.0, image.size.width, image.size.height)     
    
    # Apparently the containter constraint is need for ZPosition to work right. 
    # Setting ZPositon on the holding layer is a bad idea. At least thats what I think.
    # Might be some unccessary layers here though.
    
  	containerLayer = CALayer.layer
  	containerLayer.bounds        = self.layer.frame
  	containerLayer.layoutManager = CAConstraintLayoutManager.layoutManager()
    containerLayer.constraints   = NSArray.arrayWithObjects(CAConstraint.constraintWithAttribute(KCAConstraintMidX,
                                                               relativeTo:"superlayer", 
                                                                attribute:KCAConstraintMidX), 
                                    CAConstraint.constraintWithAttribute(KCAConstraintMidY,
                                                               relativeTo:"superlayer", 
                                                                attribute:KCAConstraintMidY),
                                    nil)
    
  	holderLayer = CALayer.layer
  	holderLayer.bounds        = aLayerRect
  	holderLayer.layoutManager = CAConstraintLayoutManager.layoutManager()
  	holderLayer.constraints   = NSArray.arrayWithObjects(CAConstraint.constraintWithAttribute(KCAConstraintMidX,
  														  relativeTo:"superlayer", 
  														   attribute:KCAConstraintMidX), 
  							   CAConstraint.constraintWithAttribute(KCAConstraintMidY, 
  														  relativeTo:"superlayer",
  														   attribute:KCAConstraintMidY),
  							   nil)
       
    
  	imageLayer = CALayer.layer
  	imageLayer.bounds           = aLayerRect
  	imageLayer.contentsGravity  = KCAGravityResizeAspectFill
    imageLayer.contents         = image.CGImageForProposedRect(aLayerRect, context:NSGraphicsContext.currentContext, hints:nil)
    imageLayer.constraints      = NSArray.arrayWithObjects(CAConstraint.constraintWithAttribute(KCAConstraintMidX,
                                                         relativeTo:"superlayer", 
                                                            attribute:KCAConstraintMidX), 
                                   CAConstraint.constraintWithAttribute(KCAConstraintMidY, 
                                                           relativeTo:"superlayer",
                                                            attribute:KCAConstraintMidY),
                                nil)
    
    
  	containerLayer.setValue(imageLayer, forKey:"__imageLayer")
  	containerLayer.setValue(holderLayer, forKey:"__holderLayer")
    
  	containerLayer.setValue(NSNumber.numberWithFloat(0.0), forKey:"__angleX")
    containerLayer.setValue(NSNumber.numberWithFloat(0.0), forKey:"__angleY")
    
  	holderLayer.addSublayer(imageLayer)
    containerLayer.addSublayer(holderLayer)
    
  	return containerLayer
  end  
  
  def updateZSidePosition(sender)
    newZPosition = sender.floatValue

  	layerTransform = CATransform3DIdentity
    layerTransform.m34 = 1.0 / newZPosition if newZPosition != 0
         

    CATransaction.begin()
    CATransaction.setValue(NSNumber.numberWithBool(true), forKey:KCATransactionDisableActions)           
    
    # Use below for animation  
    # CATransaction.setValue(NSNumber.numberWithFloat(3.0), forKey:KCATransactionAnimationDuration)

    containerLayer = self.layer.sublayers.objectAtIndex(0)
    containerLayer.sublayerTransform = layerTransform    
    
  	CATransaction.commit()

    zPositionLabel.setStringValue(newZPosition)
  end  
  
  def updateAngleX(sender)
    angleXDeg = sender.floatValue()
    angleXRad = (sender.floatValue / 180.0 ) * Math::PI
    
    CATransaction.begin()
    CATransaction.setValue(NSNumber.numberWithBool(true), forKey:KCATransactionDisableActions) 
      
    # Use below for animation  
    # CATransaction.setValue(NSNumber.numberWithFloat(3.0), forKey:KCATransactionAnimationDuration)
    
    containerLayer = self.layer.sublayers.objectAtIndex(0)
    holder         = containerLayer.valueForKey("__holderLayer")   
    
    containerLayer.setValue(NSNumber.numberWithFloat(angleXRad), forKey:"__angleX")     
    
    angleY = containerLayer.valueForKey("__angleY").floatValue
    holderTransform  = CATransform3DMakeRotation(angleXRad, 1.0, 0.0, 0.0)
    holderTransform  = CATransform3DRotate(holderTransform, angleY, 0.0, 1.0, 0.0)
    holder.transform = holderTransform
    
  	CATransaction.commit()

    angleXLabel.setStringValue(angleXDeg)
  end  
  
  def updateAngleY(sender)
    angleYDeg = sender.floatValue
    angleYRad = (sender.floatValue / 180.0) * Math::PI

    CATransaction.begin()
    CATransaction.setValue(NSNumber.numberWithBool(true), forKey:KCATransactionDisableActions)   
    
    # Use below for animation
    # CATransaction.setValue(NSNumber.numberWithFloat(3.0), forKey:KCATransactionAnimationDuration)
    
    containerLayer = self.layer.sublayers.objectAtIndex(0)
    holder         = containerLayer.valueForKey("__holderLayer")
    
    containerLayer.setValue(NSNumber.numberWithFloat(angleYRad), forKey:"__angleY")
    
    angleX = containerLayer.valueForKey("__angleX").floatValue
    holderTransform  = CATransform3DMakeRotation(angleX, 1.0, 0.0, 0.0)
    holderTransform  = CATransform3DRotate(holderTransform, angleYRad, 0.0, 1.0, 0.0)
    holder.transform = holderTransform
    
    CATransaction.commit

    angleYLabel.setStringValue(angleYDeg)
  end
end