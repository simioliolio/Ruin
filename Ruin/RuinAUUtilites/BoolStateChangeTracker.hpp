//
//  BoolStateChangeTracker.hpp
//  RuinStutter
//
//  Created by Simon Haycock on 25/06/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

#ifndef BoolStateChangeTracker_hpp
#define BoolStateChangeTracker_hpp

#include <stdio.h>

enum BoolStateChangeResult {
    BoolStateChangeResultUnchanged = 0,
    BoolStateChangeResultEnabled = 1,
    BoolStateChangeResultDisabled = 2
};

class BoolStateChangeTracker {
    
public:
    
    BoolStateChangeTracker(bool startingState) {
        state = startingState;
    }
    
    BoolStateChangeResult hasStateChanged(bool updatedState) {
        if (updatedState == state) {
            return BoolStateChangeResultUnchanged;
        } else if (state == false && updatedState == true) {
            state = updatedState;
            return BoolStateChangeResultEnabled;
        } else if (state == true && updatedState == false) {
            state = updatedState;
            return BoolStateChangeResultDisabled;
        } else {
            return BoolStateChangeResultUnchanged;
        }
    }
    
private:
    bool state;
};

#endif /* BoolStateChangeTracker_hpp */
