import argparse
from pandas import DataFrame
from pandas import read_csv



# -------FUNCTIONS-----------------------------------------------------------
class AnnotationData:
    def __init__(self, infile, name, mini, maxi, include, outpath, only_ids, q, c):
        self.isQuantitative=q
        self.isCategorical=c
        
        self.AnnotatorName = name
        self.filepath = infile
        self.outfile = outpath + ".filtered.tsv"
        self.idOnly = only_ids
        self.include = include
        self.minimum = mini
        self.maximum = maxi

    def load_annotation_data(self):
        try:
            self.anno_data = read_csv(self.filepath, sep="\t", index_col=False, compression='gzip',usecols=["#Chrom", "Pos", "Ref", "Alt", "Type", "GeneName", self.AnnotatorName])
        except ValueError as err:
            print("Error in: AnnotationData.load_annotation_data(): ", err)
            parser.exit(message="Exiting\n")
        n = len(self.anno_data)
        print("Loaded", n, "variants.")

    def filter_data(self):
        self.load_annotation_data()
        if self.isCategorical:
            sub_data = self.anno_data.loc[self.anno_data[self.AnnotatorName].isin(self.include)]
        elif self.isQuantitative:
            if self.minimum == -1 * float('inf'):
                sub_data = self.anno_data.loc[(self.anno_data[self.AnnotatorName] < self.maximum)]
            elif self.maximum == float('inf'):
                sub_data = self.anno_data.loc[(self.anno_data[self.AnnotatorName] > self.minimum)]
            else:
                sub_data = self.anno_data.loc[((self.anno_data[self.AnnotatorName] > self.minimum) & (
                            self.anno_data[self.AnnotatorName] < self.maximum))]
        print(len(sub_data), "variants remaining after filter.")
        return sub_data

    def output_list_of_variants(self):
        sub_data = self.filter_data()
        sub_data = sub_data.assign(variantID=variant_id_spec(sub_data))
        if self.idOnly:
            sub_data.to_csv(self.outfile, columns=["variantID"],
                            index=False, sep="\t")
        else:
            sub_data.to_csv(self.outfile, columns=["variantID", "Type", "GeneName", self.AnnotatorName],
                            index=False, sep="\t")
    
    def summarize_annotator(self):
        self.load_annotation_data()
        if self.isCategorical:
            print("Unique values:", self.anno_data[self.AnnotatorName].unique())
            print(self.anno_data[self.AnnotatorName].value_counts())
        elif self.isQuantitative:
            print(self.anno_data[self.AnnotatorName].describe())


def variant_id_spec(df, chrom="#Chrom", pos="Pos", ref="Ref", alt="Alt"):
    df = df.astype({chrom: str, pos:str, ref:str, alt:str})
    return df[chrom] + ":" + df[pos] + ":" + df[ref] + ":" + df[alt]


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("file", help="path to annotation file", type=str)
    parser.add_argument("-g", "--getAnnotators", action='store_true')
    parser.add_argument("-s", "--summarize", help="Summarize the values of an annotator", action="store_true")
    parser.add_argument("-a", "--annotator",help="Annotator(s) to use, space separated list of annotators")
    parser.add_argument("-q", "--isQuantitative", action='store_true')
    parser.add_argument("-c", "--isCategorical", action='store_true')
    parser.add_argument("-x", "--maximum", help="Maximum value for continuous annotation", action='store', type=float, default=float('inf'))
    parser.add_argument("-m", "--minimum", help="Minimum value for continuous annotation", action='store', type=float, default=float('inf'))
    parser.add_argument("-i", "--include", help="space separated list of categorical values", nargs="+")
    parser.add_argument("-o", "--output", help="Output path prefix", type=str, default="filter")
    parser.add_argument("-d", "--idOnly", help="Only output variant IDS", action='store_true')
    parser.add_argument("-v", "--verbose", help="Print verbose messages", action='store_true')
    args = parser.parse_args()
    
    try:
        assert (args.isQuantitative != args.isCategorical) or args.getAnnotators
    except AssertionError:
        if sum([args.isQuantitative, args.isCategorical]) == 0:
            parser.exit(message="Error :: One of -c and -q must be provided.\n")
        else:
            parser.exit(message="Error :: Only one of -c and -q can be provided.\n")
    
    if args.verbose:
        print("Annotator:", args.annotator)
        print(args.maximum)
        print(args.include is None)

    filter_obj = AnnotationData(infile=args.file, name=args.annotator, mini=args.minimum, maxi=args.maximum, include=args.include, outpath=args.output, only_ids=args.idOnly, q=args.isQuantitative, c=args.isCategorical)
    if args.summarize:
        filter_obj.summarize_annotator()
    elif args.getAnnotators:
        import pandas as pd
        columns = pd.read_csv(args.file, sep="\t", compression="gzip", nrows=1, header=None)
        for field in columns.values:
            print(field)
    else:
        filter_obj.output_list_of_variants()
        if args.verbose:
            print("Variants saved to:", filter_obj.outfile)

    


