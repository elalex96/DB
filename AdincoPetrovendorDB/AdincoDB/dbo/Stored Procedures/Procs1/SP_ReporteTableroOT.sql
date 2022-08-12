CREATE PROCEDURE [dbo].[SP_ReporteTableroOT]--10,10038
@idUsuario INT,
@idContrato INT
AS
BEGIN
    SELECT  OT_BI_Tablero.*
        FROM OT_BI_Tablero (NOLOCK)
    JOIN
        OT_Solicitud (NOLOCK)
        ON OT_Solicitud.IdOTSolicitud = OT_BI_Tablero.IdOTSolicitud
    JOIN
        SC_SubContrato (NOLOCK)
        ON SC_SubContrato.IdSubContrato = OT_Solicitud.IdSubContrato
			AND SC_SubContrato.IdContrato = @idContrato
    JOIN
        AP_UsuarioCentroCosto (NOLOCK)
        ON AP_UsuarioCentroCosto.IdCentroCosto = OT_Solicitud.IdCentroCosto
			AND AP_UsuarioCentroCosto.IdUsuario = @idUsuario
			AND SC_SubContrato.IdContrato = @idContrato
END
 
                                       

 
 
 
 