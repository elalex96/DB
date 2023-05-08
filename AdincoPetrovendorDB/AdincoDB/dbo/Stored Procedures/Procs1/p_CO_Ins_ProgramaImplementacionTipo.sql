create proc p_CO_Ins_ProgramaImplementacionTipo
@Id	tinyint,
@Descripcion	varchar(250),
@IsEliminado	bit,
@IdContratista	int,
@IdContrato	int
as

	select @Id = isnull(max(id),0) +1
	from CO_ProgramaImplementacionTipo
	

INSERT INTO [dbo].[CO_ProgramaImplementacionTipo]
           ([Id]
           ,[Descripcion]
           ,[IsEliminado]
           ,[IdContratista]
           ,[IdContrato])
     VALUES
           (@Id,
          @Descripcion,
           @IsEliminado,
          @IdContratista,
          @IdContrato)
