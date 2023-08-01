import { Injectable } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Organization } from 'src/organizations/entities/organization.entity';
import { adminEnroller } from 'src/users/helpers/AdminEnroller';
import { randomUUID } from 'crypto';
import { resolve } from 'path';

@Injectable()
export class UsersServiceHLF {
  constructor(
    @InjectRepository(Organization)
    private organizationsRepository: Repository<Organization>,
  ) {}

  async create(createUserDto: CreateUserDto) {
    let wallet_id = '';
    const organization = await this.organizationsRepository.findOneBy({
      id: createUserDto.organization_id,
    });
    const uuid = randomUUID();
    const ccpPath = resolve(
      '..',
      'network',
      'organizations',
      'peerOrganizations',
      organization.address,
      `connection-${organization.name.toLowerCase()}.json`,
    );

    try {
      if (createUserDto.role === 'admin') {
        wallet_id = `ADMIN-${uuid}`;
        await adminEnroller(
          wallet_id,
          ccpPath,
          `ca.${organization.address}`,
          createUserDto.username,
          'adminpw',
        );
      } else {

      }
    } catch (error) {}

    return wallet_id;
  }
}
