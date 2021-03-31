# SKParticleEmitter

This is a Swift port of the SKParticleEmitter by 71Squared.

This Swift class is heavily based on the original ObjectiveC classes available within the repository at:

    https://github.com/71squared/ParticleEmitterDemo-SK

##Dependencies

###XML Parsing
Rather than port the entire TBXML codebase, this class employes the XMLCoder package located at:

    https://github.com/MaxDesiatov/XMLCoder.git
    
to parse the emitter configuration files.

As a result of that, and some Swift eccentricities (or perhaps my lack of Swift expertise), this
class makes use of a number of wrapper types for the emitter properties to make it simpler to
use XMLCoder.

There _may_ be some performance penalties, but I've not seen any in my early tests.

###Gunzip

The excellent ParticleDesigner app (https://www.71squared.com/particledesigner) is able to
embed the texture used by an emitter.  When it does, it compresses the texture using gZip,
and then Base64 encodes it.

Again, rather than rely on the ObjC code provided with TBXML, I chose to add a dependency to 
the Gzip Swift package, which can be found at:

    https://github.com/1024jp/GzipSwift
    
##Installation

### Swift Package Manager

1. Add this package to your package.swift.


