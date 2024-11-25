/**
 * File: BehaviorWireTest.cpp
 *
 * Author: Wire
 * Created: 2024-11-25
 *
 * Description: Test behavior that makes the robot say "hello world" upon activation of the "test_wire" intent.
 *
 * Copyright: Anki, Inc. 2024
 **/

#include "engine/aiComponent/behaviorComponent/behaviors/victor/behaviorWireTest.h"
#include "engine/actions/sayTextAction.h"
#include "engine/aiComponent/behaviorComponent/userIntentComponent.h"
#include "engine/aiComponent/behaviorComponent/userIntents.h"
#include "util/logging/logging.h"

namespace Anki {
namespace Vector {

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
BehaviorWireTest::InstanceConfig::InstanceConfig()
{
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
BehaviorWireTest::DynamicVariables::DynamicVariables()
{
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
BehaviorWireTest::BehaviorWireTest(const Json::Value& config)
 : ICozmoBehavior(config)
{
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
BehaviorWireTest::~BehaviorWireTest()
{
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
bool BehaviorWireTest::WantsToBeActivatedBehavior() const
{
  return true;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void BehaviorWireTest::GetBehaviorOperationModifiers(BehaviorOperationModifiers& modifiers) const
{
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void BehaviorWireTest::GetAllDelegates(std::set<IBehavior*>& delegates) const
{
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void BehaviorWireTest::GetBehaviorJsonKeys(std::set<const char*>& expectedKeys) const
{
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void BehaviorWireTest::OnBehaviorActivated() 
{
  _dVars = DynamicVariables();

  auto& uic = GetBehaviorComp<UserIntentComponent>();
  UserIntentPtr activeIntentPtr = uic.GetUserIntentIfActive(USER_INTENT(test_wire));

  if (activeIntentPtr) {
    // Log that the behavior was activated
    PRINT_NAMED_INFO("BehaviorWireTest.OnBehaviorActivated", "Activated 'test_wire' intent");

    // Create and delegate a SayTextAction to say "Hello World"
    auto* sayHelloAction = new SayTextAction("Hello World", SayTextAction::AudioTtsProcessingStyle::Unprocessed);
    DelegateIfInControl(sayHelloAction, [](const ActionResult& result) {
      if (result == ActionResult::SUCCESS) {
        PRINT_NAMED_INFO("BehaviorWireTest.OnBehaviorActivated", "Successfully said 'Hello World'");
      } else {
        PRINT_NAMED_WARNING("BehaviorWireTest.OnBehaviorActivated", "Failed to say 'Hello World'");
      }
    });
  } else {
    PRINT_NAMED_WARNING("BehaviorWireTest.OnBehaviorActivated", "No active 'test_wire' intent found");
  }
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void BehaviorWireTest::BehaviorUpdate() 
{
  // No periodic updates are necessary for this behavior
}

}
}
