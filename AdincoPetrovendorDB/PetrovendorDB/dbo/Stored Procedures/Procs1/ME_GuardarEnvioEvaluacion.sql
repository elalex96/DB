

Create procedure [dbo].[ME_GuardarEnvioEvaluacion]
	@IdMatrizEvaluacion INT,
	@IdProveedorEvaluado INT,
	@IdUsuarioEnviado int
as 
begin
	INSERT INTO dbo.ME_EnvioEvaluacion
	(
	    IdMatrizEvaluacion,
	    IdProveedorEvaluado,
	    FechaEnvio,
	    Contestado,
	    IdUsuarioEnviado
	)
	VALUES
	(   @IdMatrizEvaluacion,    -- IdMatrizEvaluacion - int
	    @IdProveedorEvaluado,   -- IdProveedorEvaluado - int
	    GETDATE(),				-- FechaEnvio - smalldatetime
	    0,						-- Contestado - bit
	    @IdUsuarioEnviado		-- IdUsuarioEnviado - int
	)
end


