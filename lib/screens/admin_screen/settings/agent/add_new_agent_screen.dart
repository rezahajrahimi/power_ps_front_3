import 'package:flutter/material.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/screens/admin_screen/settings/agent/agent_form_screen.dart';

class AddNewAgentScreen extends StatelessWidget {
  const AddNewAgentScreen({super.key, this.copyFromAgent});

  final User? copyFromAgent;

  @override
  Widget build(BuildContext context) {
    return AgentFormScreen(
      mode: AgentFormMode.create,
      copyFromAgent: copyFromAgent,
    );
  }
}
