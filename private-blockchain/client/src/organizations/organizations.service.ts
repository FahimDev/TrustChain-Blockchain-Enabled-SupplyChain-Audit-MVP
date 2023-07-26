import { Injectable } from '@nestjs/common';
import { CreateOrganizationDto } from './dto/create-organization.dto';
import { UpdateOrganizationDto } from './dto/update-organization.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Organization } from './entities/organization.entity';
import { Repository } from 'typeorm';

@Injectable()
export class OrganizationsService {
  constructor(
    @InjectRepository(Organization)
    private organizationsRepository: Repository<Organization>,
  ) {}

  async create(createOrganizationDto: CreateOrganizationDto) {
    return await this.organizationsRepository.save(createOrganizationDto);
  }

  findAll() {
    return this.organizationsRepository.find();
  }

  findOne(id: number) {
    return this.organizationsRepository.findOneBy({ id });
  }

  async update(id: number, updateOrganizationDto: UpdateOrganizationDto) {
    return await this.organizationsRepository.update(id, updateOrganizationDto);
  }

  async remove(id: number) {
    return await this.organizationsRepository.delete(id);
  }
}
