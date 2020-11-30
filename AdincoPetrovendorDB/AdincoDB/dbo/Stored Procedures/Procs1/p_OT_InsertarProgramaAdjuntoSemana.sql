
CREATE PROC p_OT_InsertarProgramaAdjuntoSemana
(
	@pIdOTSolicitudMaterial		int,
	@pFechaInicioSemana			datetime,
	@pFechaFinSemana			datetime,
	@pAWSDocumentoId			int,
	@pCreadoPor					varchar(150)
)
as
begin

	declare @ID int
    
	select	@ID = ISNULL(MAX(ID),0) + 1
	from	[OT_ProgramaAdjuntoSemana]

	insert into [OT_ProgramaAdjuntoSemana]
				(
					ID,					IdOTSolicitudMaterial,		FechaInicioSemana,		FechaFinSemana,
					AWSDocumentoID,		CreadoPor,					CreadoEl
				)
	values		(	
					@ID,				@pIdOTSolicitudMaterial,	@pFechaInicioSemana,	@pFechaFinSemana,
					@pAWSDocumentoId,	@pCreadoPor,				GETDATE()
				)
	
end

