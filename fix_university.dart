import 'dart:io';

void main() {
  final file = File(r'lib\screens\universities\university_detail_screen.dart');
  String content = file.readAsStringSync();
  
  // replace widget methods to take context
  content = content.replaceAll('Widget _buildHeader() {', 'Widget _buildHeader(BuildContext context) {');
  content = content.replaceAll('_buildHeader(),', '_buildHeader(context),');
  
  content = content.replaceAll('Widget _buildQuickInfo() {', 'Widget _buildQuickInfo(BuildContext context) {');
  content = content.replaceAll('_buildQuickInfo(),', '_buildQuickInfo(context),');
  
  content = content.replaceAll('Widget _buildPrograms() {', 'Widget _buildPrograms(BuildContext context) {');
  content = content.replaceAll('_buildPrograms(),', '_buildPrograms(context),');
  
  content = content.replaceAll('Widget _buildFeeStructure() {', 'Widget _buildFeeStructure(BuildContext context) {');
  content = content.replaceAll('_buildFeeStructure(),', '_buildFeeStructure(context),');
  
  content = content.replaceAll('Widget _buildRequirements() {', 'Widget _buildRequirements(BuildContext context) {');
  content = content.replaceAll('_buildRequirements(),', '_buildRequirements(context),');
  
  content = content.replaceAll('Widget _buildLocation() {', 'Widget _buildLocation(BuildContext context) {');
  content = content.replaceAll('_buildLocation(),', '_buildLocation(context),');
  
  content = content.replaceAll('Widget _buildGallery() {', 'Widget _buildGallery(BuildContext context) {');
  content = content.replaceAll('_buildGallery(),', '_buildGallery(context),');

  content = content.replaceAll('Widget _buildSectionTitle(String title) {', 'Widget _buildSectionTitle(BuildContext context, String title) {');
  content = content.replaceAll('_buildSectionTitle(', '_buildSectionTitle(context, ');
  
  file.writeAsStringSync(content);
}
