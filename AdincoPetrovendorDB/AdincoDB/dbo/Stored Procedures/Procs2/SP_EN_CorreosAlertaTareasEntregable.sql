CREATE PROCEDURE SP_EN_CorreosAlertaTareasEntregable
    @Dia int,   
    @Mes int,
	@Anio int
	--FechaEnvio,Tarea,Aprueba,Revisa,Aprueba,Receptor,FechaLimiteAprobacion Entregable
	AS   
	SELECT FechaEnvioMensajeAtrasoRevision,EN.DocumentoEntregable,CE.Elabora, CE.Revisa,CE.Aprueba,CE.ReceptorAlerta,FechasLimiteAprobacion 
	FROM EN_InstanciasEntregable as IE
	INNER JOIN  EN_ContratoEntregable as CE on  IE.IdContratoEntregable = CE.IdContratoEntregable
	INNER JOIN EN_ENTREGABLE as EN on CE.IdEntregable = EN.IdEntregable
	AND EN.BITJOA = 0
	where DAY(FechaEnvioMensajeAtrasoRevision)= @Dia and MONTH(FechaEnvioMensajeAtrasoRevision) = @Mes and YEAR(FechaEnvioMensajeAtrasoRevision)= @Anio
