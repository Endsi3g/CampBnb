/**
 * Script pour générer un rapport d'erreurs depuis Sentry
 * Utilisé par GitHub Actions pour les rapports quotidiens
 */

const fs = require('fs');
const path = require('path');

// Lire les erreurs depuis le fichier JSON généré par Sentry CLI
const errorsFile = path.join(__dirname, '..', 'errors-24h.json');
let errors = [];

try {
  const errorsData = fs.readFileSync(errorsFile, 'utf8');
  errors = JSON.parse(errorsData);
} catch (error) {
  console.error('Erreur lors de la lecture du fichier d\'erreurs:', error);
  process.exit(1);
}

// Générer le rapport
function generateReport() {
  const report = {
    date: new Date().toISOString(),
    totalErrors: errors.length,
    errorsByLevel: {},
    errorsByType: {},
    topErrors: [],
  };

  // Analyser les erreurs
  errors.forEach((error) => {
    // Par niveau
    const level = error.level || 'unknown';
    report.errorsByLevel[level] = (report.errorsByLevel[level] || 0) + 1;

    // Par type
    const type = error.type || 'unknown';
    report.errorsByType[type] = (report.errorsByType[type] || 0) + 1;
  });

  // Top 10 erreurs les plus fréquentes
  const errorCounts = {};
  errors.forEach((error) => {
    const title = error.title || 'Unknown Error';
    errorCounts[title] = (errorCounts[title] || 0) + 1;
  });

  report.topErrors = Object.entries(errorCounts)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 10)
    .map(([title, count]) => ({ title, count }));

  return report;
}

// Générer le markdown
function generateMarkdown(report) {
  let markdown = `# Rapport d'Erreurs - ${new Date().toLocaleDateString('fr-FR')}\n\n`;
  
  markdown += `## Résumé\n\n`;
  markdown += `- **Total d'erreurs** : ${report.totalErrors}\n`;
  markdown += `- **Date** : ${new Date(report.date).toLocaleString('fr-FR')}\n\n`;

  markdown += `## Erreurs par niveau\n\n`;
  Object.entries(report.errorsByLevel)
    .sort((a, b) => b[1] - a[1])
    .forEach(([level, count]) => {
      markdown += `- **${level}** : ${count}\n`;
    });

  markdown += `\n## Erreurs par type\n\n`;
  Object.entries(report.errorsByType)
    .sort((a, b) => b[1] - a[1])
    .forEach(([type, count]) => {
      markdown += `- **${type}** : ${count}\n`;
    });

  markdown += `\n## Top 10 erreurs les plus fréquentes\n\n`;
  report.topErrors.forEach((error, index) => {
    markdown += `${index + 1}. **${error.title}** (${error.count} occurrences)\n`;
  });

  markdown += `\n## Recommandations\n\n`;
  
  if (report.totalErrors > 100) {
    markdown += `⚠️ **Attention** : Nombre élevé d'erreurs détectées. Une investigation est recommandée.\n\n`;
  }
  
  if (report.errorsByLevel.fatal > 0) {
    markdown += `🚨 **Critique** : ${report.errorsByLevel.fatal} erreur(s) fatale(s) détectée(s). Action immédiate requise.\n\n`;
  }

  if (report.errorsByLevel.error > 50) {
    markdown += `⚠️ **Alerte** : ${report.errorsByLevel.error} erreur(s) détectée(s). Vérification recommandée.\n\n`;
  }

  return markdown;
}

// Générer et sauvegarder le rapport
const report = generateReport();
const markdown = generateMarkdown(report);

const reportFile = path.join(__dirname, '..', 'error-report.md');
fs.writeFileSync(reportFile, markdown, 'utf8');

console.log('✅ Rapport généré avec succès:', reportFile);
console.log(`📊 Total d'erreurs: ${report.totalErrors}`);

