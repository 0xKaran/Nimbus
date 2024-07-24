import dns.resolver
import sys

def remove_trailing_dot(domain):
    return domain.rstrip('.')

def check_cname(domain):
    try:
        answers = dns.resolver.resolve(remove_trailing_dot(domain), 'CNAME')
        cnames = [answer.target.to_text() for answer in answers]
        if cnames:
            cnames_without_dot = [cname.rstrip('.') for cname in cnames]
            print(f"[CNAME-DOMAIN] : {', '.join(cnames_without_dot)} <- {domain}")
    except dns.resolver.NXDOMAIN:
        pass  # Domain not found, ignore and move to the next domain
    except dns.resolver.NoAnswer:
        pass  # No CNAME record found, ignore and move to the next domain
    except dns.exception.DNSException as e:
        print(f"{domain} - DNS error: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <path_to_domain_list>")
        sys.exit(1)

    domain_list_file = sys.argv[1]
    
    try:
        with open(domain_list_file, "r") as file:
            domains = file.read().splitlines()
    except FileNotFoundError:
        print(f"Error: File '{domain_list_file}' not found.")
        sys.exit(1)

    for domain in domains:
        check_cname(domain)
