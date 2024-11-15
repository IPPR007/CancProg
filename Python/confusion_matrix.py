import numpy as np  
import matplotlib.pyplot as plt  
import seaborn as sns  
import pandas as pd  

def load_confusion_matrices(file_path):  

    try:  

        df = pd.read_csv(file_path)  

        n_folds = df['fold'].nunique()  
        confusion_matrices = np.zeros((n_folds, 2, 2))  

        for fold in range(1, n_folds + 1):  
            fold_data = df[df['fold'] == fold]  
            for _, row in fold_data.iterrows():  
                confusion_matrices[fold-1, int(row['actual']), int(row['predicted'])] = row['count']  
        
        return confusion_matrices  
    
    except Exception as e:  
        print(f"Error loading confusion matrices: {str(e)}")  
        return None  

def calculate_metrics(cm):  

    TP = cm[1, 1]  
    TN = cm[0, 0]  
    FP = cm[0, 1]  
    FN = cm[1, 0]  
    
    accuracy = (TP + TN) / np.sum(cm)  
    sensitivity = TP / (TP + FN) if (TP + FN) != 0 else 0  
    specificity = TN / (TN + FP) if (TN + FP) != 0 else 0  
    precision = TP / (TP + FP) if (TP + FP) != 0 else 0  
    f1 = 2 * (precision * sensitivity) / (precision + sensitivity) if (precision + sensitivity) != 0 else 0  
    
    return {  
        'Accuracy': accuracy,  
        'Sensitivity': sensitivity,  
        'Specificity': specificity,  
        'Precision': precision,  
        'F1 Score': f1  
    }  

def plot_confusion_matrices(total_cm, avg_cm, save_path_prefix):  

    plt.style.use('seaborn')  
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))  

    colors = ['#fff5eb', '#fee6ce', '#fdd0a2', '#fdae6b', '#fd8d3c', '#f16913', '#d94801', '#8c2d04']  
    custom_cmap = sns.color_palette(colors, as_cmap=True)  

    sns.heatmap(total_cm,  
                annot=True,  
                fmt='d',  
                cmap=custom_cmap,  
                ax=ax1,  
                cbar=True,  
                xticklabels=['0', '1'],  
                yticklabels=['0', '1'],  
                square=True,  
                annot_kws={'size': 12, 'weight': 'bold'})  
    
    ax1.set_title('Total Confusion Matrix\n(Sum of 5 folds)', pad=10, fontsize=12)  
    ax1.set_xlabel('Predicted', labelpad=10)  
    ax1.set_ylabel('Actual', labelpad=10)  

    sns.heatmap(avg_cm,  
                annot=True,  
                fmt='.2f',  
                cmap=custom_cmap,  
                ax=ax2,  
                cbar=True,  
                xticklabels=['0', '1'],  
                yticklabels=['0', '1'],  
                square=True,  
                annot_kws={'size': 12, 'weight': 'bold'})  
    
    ax2.set_title('Average Confusion Matrix', pad=10, fontsize=12)  
    ax2.set_xlabel('Predicted', labelpad=10)  
    ax2.set_ylabel('Actual', labelpad=10)  
    
    plt.tight_layout()  

    plt.savefig(f'{save_path_prefix}.pdf', format='pdf', dpi=300, bbox_inches='tight', transparent=True)  
    plt.savefig(f'{save_path_prefix}.png', dpi=300, bbox_inches='tight', facecolor='white')  
    
    plt.show()  

def main():  

    confusion_matrices = load_confusion_matrices('confusion_matrices.csv')  
    if confusion_matrices is None:  
        return  

    avg_cm = np.mean(confusion_matrices, axis=0)  
    total_cm = np.sum(confusion_matrices, axis=0)  

    plot_confusion_matrices(total_cm, avg_cm, 'confusion_matrices_lr')  

    total_metrics = calculate_metrics(total_cm)  
    print("\nTotal metrics across all folds:")  
    for metric, value in total_metrics.items():  
        print(f"{metric}: {value:.3f}")  
  
    print("\nTotal Confusion Matrix:")  
    print(total_cm)  
    print("\nAverage Confusion Matrix:")  
    print(avg_cm)  
  
    print("\nMetrics for each fold:")  
    for i in range(len(confusion_matrices)):  
        metrics = calculate_metrics(confusion_matrices[i])  
        print(f"\nFold {i + 1}:")  
        for metric, value in metrics.items():  
            print(f"{metric}: {value:.3f}")  

if __name__ == "__main__":  
    main()