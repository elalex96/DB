IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'SP_ReporteTableroOT'
    )
    DROP PROCEDURE SP_ReporteTableroOT;
GO
CREATE PROCEDURE [dbo].[SP_ReporteTableroOT]
@idUsuario INT,
@idContrato INT
AS
BEGIN
    SELECT  OT_BI_Tablero.*
        FROM 
		SC_SubContrato (NOLOCK)		
    JOIN
		OT_Solicitud (NOLOCK)
		ON 	 SC_SubContrato.IdContrato = @idContrato
		AND SC_SubContrato.IdSubContrato = OT_Solicitud.IdSubContrato
	JOIN
        AP_UsuarioCentroCosto (NOLOCK)
        ON OT_Solicitud.IdCentroCosto	=	AP_UsuarioCentroCosto.IdCentroCosto
			AND AP_UsuarioCentroCosto.IdUsuario = @idUsuario
			AND SC_SubContrato.IdContrato = @idContrato
    JOIN
        OT_BI_Tablero (NOLOCK)
        ON OT_Solicitud.IdOTSolicitud = OT_BI_Tablero.IdOTSolicitud
    
END
 