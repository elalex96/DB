
CREATE Proc p_CO_InsertarProgramaImplementa
@pIdProgramaImplementa	int out,
@pIdContrato	int,
@pIdTipoPrograma	tinyint,
@pFechaInicio	datetime,
@pFechaFin	datetime,
@pCreadoPor	int
as

	select @pIdProgramaImplementa  =isnull(max(IdProgramaImplementa),0) +1
	from [CO_ProgramaImplementa]

	INSERT INTO [dbo].[CO_ProgramaImplementa]
			   ([IdProgramaImplementa]
			   ,[IdContrato]
			   ,[IdTipoPrograma]
			   ,[FechaInicio]
			   ,[FechaFin]
			   ,[CreadoEl]
			   ,[CreadoPor]
			   ,[ModificadoEl]
			   ,[ModificadoPor]
			   ,Activo)
		 VALUES
			   (@pIdProgramaImplementa, 
			   @pIdContrato, 
			   @pIdTipoPrograma,
			   @pFechaInicio,
			   @pFechaFin,
			   getdate(),
			   @pCreadoPor,
			   null,
			   null,
			   1)

