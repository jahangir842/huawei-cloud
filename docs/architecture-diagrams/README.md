# Architecture Diagrams

Store your Huawei Cloud architecture diagrams in this directory.

## Recommended Tools

- [draw.io](https://app.diagrams.net/) - Free online diagram software
- [Lucidchart](https://www.lucidchart.com/) - Web-based diagramming application
- [Mermaid](https://mermaid-js.github.io/mermaid/#/) - Markdown-based diagramming

## Diagram Types to Create

As you progress through your learning journey, consider creating the following types of diagrams:

1. **Network Architecture**
   - VPC layout
   - Subnet organization
   - Security group relationships
   - VPN/Direct Connect configurations

2. **Application Architecture**
   - Multi-tier applications
   - Microservices deployments
   - Serverless architectures
   - Container-based solutions

3. **Data Flow Diagrams**
   - Data processing pipelines
   - ETL workflows
   - Analytics architectures

4. **High Availability Designs**
   - Multi-AZ deployments
   - Disaster recovery setups
   - Global load balancing

5. **Security Architecture**
   - IAM structure
   - Encryption implementation
   - Security controls and monitoring

## Naming Convention

Use a consistent naming convention for your diagrams:

```
[project]-[component]-[version]-[date].drawio
```

Example: `ecommerce-network-v1-20250517.drawio`

## Example Diagram

```mermaid
graph TD
    Internet((Internet)) --> ELB[Elastic Load Balancer]
    ELB --> ECS1[ECS Web Server 1]
    ELB --> ECS2[ECS Web Server 2]
    ECS1 --> RDS[(RDS Database)]
    ECS2 --> RDS
    ECS1 --> OBS[Object Storage]
    ECS2 --> OBS
    
    subgraph "VPC"
        subgraph "Public Subnet AZ1"
            ECS1
        end
        subgraph "Public Subnet AZ2"
            ECS2
        end
        subgraph "Private Subnet"
            RDS
        end
    end
