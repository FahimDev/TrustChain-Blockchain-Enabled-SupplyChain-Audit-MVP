import { Module } from '@nestjs/common';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './entities/user.entity';
import { Organization } from 'src/organizations/entities/organization.entity';
import { UsersServiceHLF } from './users.service.hlf';

@Module({
  imports: [TypeOrmModule.forFeature([User, Organization])],
  controllers: [UsersController],
  providers: [UsersService, UsersServiceHLF]
})
export class UsersModule {}
