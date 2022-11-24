CREATE PROCEDURE [dbo].[SP_EN_CorreosAlertaTareasEntregable01]--27,11,2020
    @Dia int,   
    @Mes int,
	@Anio int
	--FechaEnvio,Tarea,Aprueba,Revisa,Aprueba,Receptor,FechaLimiteAprobacion Entregable
	AS   
-- =============================================
-- Author:		Luis David De la Cruz
-- Create date: 
-- Description:	
-- =============================================

	SELECT FechaEnvioMensajeAtrasoRevision,
	EN.DocumentoEntregable,
	Case AE.EstadoID
	When 10000 
	then AE.idUsuario else  0 END  UsuarioElabora,
	Case AE.EstadoID
	When 10001
	then AE.idUsuario else 0 END  UsuarioRevision,
	Case AE.EstadoID
	When 10002
	then AE.idUsuario else 0 END UsuarioAprueba
	,CE.ReceptorAlerta
	,FechasLimiteAprobacion
	,A.EstadoID 
	,CorreoEnviado
	,IE.idInstanciaEntregable 
	FROM EN_InstanciasEntregable as IE
	INNER JOIN  EN_ContratoEntregable as CE on  IE.IdContratoEntregable = CE.IdContratoEntregable
	Join EN_Actividad A on   A.ActividadID = IE.ActividadID
	Join EN_Actividad AE on   AE.IdContratoEntregable = CE.IdContratoEntregable 
	INNER JOIN EN_ENTREGABLE as EN on CE.IdEntregable = EN.IdEntregable
		and en.bitjoa = 0
	where DAY(FechaEnvioMensajeAtrasoRevision)= @Dia and MONTH(FechaEnvioMensajeAtrasoRevision) = @Mes and YEAR(FechaEnvioMensajeAtrasoRevision)= @Anio
	AND AE.EstadoID<>10003
	--Select * from en_estado

