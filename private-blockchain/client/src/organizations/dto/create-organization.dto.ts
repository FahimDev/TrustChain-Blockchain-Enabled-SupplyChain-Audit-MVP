import { ApiProperty } from "@nestjs/swagger";

export class CreateOrganizationDto {
    @ApiProperty()
    name: string

    @ApiProperty()
    type: string

    @ApiProperty()
    address: string
}
