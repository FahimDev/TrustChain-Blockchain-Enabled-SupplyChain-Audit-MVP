import { ApiProperty } from '@nestjs/swagger';

export class CreateUserDto {
  @ApiProperty()
  username: string;

  @ApiProperty()
  password: string;

  @ApiProperty()
  wallet: string;

  @ApiProperty()
  role: string;

  @ApiProperty()
  organization_id: number;
}
