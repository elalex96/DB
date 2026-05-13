--select  dbo.fn_OT_ValidarEnviarContratista(1)
CREATE FUNCTION [dbo].[fn_OT_ValidarEnviarContratista](
	@pIdOTSolicitud int	
)
RETURNS VARCHAR(250)
BEGIN

	DECLARE @error VARCHAR(250)=''

	DECLARE @tmpMaterialCantidades TABLE  
    ( IdOTSolicitudMaterial   INT   NOT NULL ,  
      Cantidad  DECIMAL (14,2),
	  CantidadProgramada DECIMAL(14,2)

	  );  

	INSERT INTO @tmpMaterialCantidades
	(
	    IdOTSolicitudMaterial,
	    Cantidad,
	    CantidadProgramada
	)
	SELECT IdOTSolicitudMaterial,
		Cantidad,
		0.0
	FROM dbo.OT_SolicitudMaterial 
	WHERE IdOTSolicitud = @pIdOTSolicitud

	UPDATE @tmpMaterialCantidades	
	SET CantidadProgramada = (
								SELECT SUM(p.Cantidad) 
								FROM dbo.OT_SolicitudPrograma P 
								WHERE P.IdOTSolicitudMaterial = t1.IdOTSolicitudMaterial
							)
	FROM @tmpMaterialCantidades t1
			
	--IF (
	--	SELECT ISNULL(SUM(cantidad),0)
	--	FROM @tmpMaterialCantidades
	--	---WHERE Cantidad <> CantidadProgramada 
	--	) 
	--	<>
	--	(
	--	SELECT ISNULL(SUM(CantidadProgramada),0)
	--	FROM @tmpMaterialCantidades
	--	--WHERE Cantidad <> CantidadProgramada 
	--	) 
	--BEGIN	
	--	SET @error = 'Es necesario terminar la captura de la programaci�n de materiales'
	--END

	if exists(
		select 1
		from OT_Solicitud 
		where IdOTSolicitud = @pIdOTSolicitud and
		datepart(mm,FechaInicio) <> datepart(mm,FechaFin) 
	)
	begin

		if not exists (
			select 1
			from [dbo].[OT_SolicitudMaterialBitacora] SMB
			INNER JOIN OT_SolicitudMaterial SM on SM.IdOTSolicitudMaterial = SMB.IdOTSolicitudMaterial
			inner join OT_Solicitud s on s.IdOTSolicitud = SM.IdOTSolicitud 
			where s.IdOTSolicitud = @pIdOTSolicitud		
		)
		begin
			SET @error = 'Es necesario capturar las cantidades y programación de los servicios'
		end

	End




	RETURN @error
end


