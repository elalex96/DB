CREATE PROCEDURE PR_SP_InsertBitacoraCalibracion
@pIdCalibracion	int,
@UsuarioId	int,
@Accion VARCHAR(250)
AS
BEGIN
INSERT INTO PR_CalibracionSistemasBitacora(
			Accion,
			CreadoPor,
			CreadoEl,
			IdCalibracion,
			IdContrato,				IdSistema,			Certificado,			Fecha,
			FechaProxima,		IntervaloCalibracion,InvervaloVerificacion,	IncertidumbreMagnitud,
			Laboratorio,		EsAcreditado,			PuertoDisponible,	ConfiguracionPuerto,
			ProtocoloComunicacion,AreaRestringida,		Observaciones,		Vigente
		)SELECT @Accion,@UsuarioId,GETDATE(),IdCalibracion,
			IdContrato,				IdSistema,			Certificado,			Fecha,
			FechaProxima,		IntervaloCalibracion,InvervaloVerificacion,	IncertidumbreMagnitud,
			Laboratorio,		EsAcreditado,			PuertoDisponible,	ConfiguracionPuerto,
			ProtocoloComunicacion,AreaRestringida,		Observaciones,		Vigente 
			FROM PR_CalibracionSistemas Where IdCalibracion = @pIdCalibracion;
END