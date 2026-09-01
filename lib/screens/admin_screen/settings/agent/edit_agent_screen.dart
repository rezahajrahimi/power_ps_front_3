import 'package:flutter/material.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/screens/admin_screen/settings/agent/agent_form_screen.dart';

class EditAgentScreen extends StatelessWidget {
  const EditAgentScreen({super.key, required this.agent});

  final User agent;

  @override
  Widget build(BuildContext context) {
    return AgentFormScreen(mode: AgentFormMode.edit, agent: agent);
  }
}
