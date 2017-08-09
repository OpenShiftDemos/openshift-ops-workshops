import csv
import os
import click

@click.command()
@click.option('--filename')
@click.option('--zone-id')

def createdns(filename, zone_id):
    with open(filename) as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            zone_name = row['Hosted Zone Name'][:-1]
            ns_0 = row['NS 0'] + "."
            ns_1 = row['NS 1'] + "."
            ns_3 = row['NS 3'] + "."
            ns_4 = row['NS 4'] + "."
    
            json_output = ('\'{"ChangeBatch":{"Comment":"OCP/CNS Test Drive Authority","Changes":[{"Action":"UPSERT","ResourceRecordSet":'
            '{"Name":"'+zone_name+'","Type":"NS","TTL":300,"ResourceRecords":'
            '[{"Value":"'+ns_0+'"},'
            '{"Value":"'+ns_1+'"},'
            '{"Value":"'+ns_3+'"},'
            '{"Value":"'+ns_4+'"}]}}]}}\'')
    
            command_prefix = 'aws route53 change-resource-record-sets --hosted-zone-id ' + zone_id + ' --cli-input-json '
    
            print( command_prefix + json_output )
            os.system( command_prefix + json_output )

if __name__ == '__main__':
    createdns()

