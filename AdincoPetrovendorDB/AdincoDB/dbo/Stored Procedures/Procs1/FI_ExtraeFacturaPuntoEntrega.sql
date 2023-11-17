IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'FI_ExtraeFacturaPuntoEntrega'
    )
    DROP PROCEDURE FI_ExtraeFacturaPuntoEntrega
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:	Reyna Olvera
-- Create date:13/04/2018
-- Description:	Extrae las facturas y nomre de puntos de entrega para saber cuales son la que ya tienen asignadas puntos de entrega
-- =============================================
CREATE PROCEDURE [dbo].[FI_ExtraeFacturaPuntoEntrega]
    @idcontrato int,
    @idUsuario  int
AS
    BEGIN

        SET NOCOUNT ON;
        SET LANGUAGE spanish;

        Select
            idFacturaPuntoEntrega,
            F.idFactura,
            folio,
            PE.Nombre,
            CP.Nombre,
            CONCAT(datename(month, MesReporte), ' ', YEAR(MesReporte)) AS MesReporte,
			FP.CreadoEl,
			isnull(U.Nombre,'') as CreadoPor
        from
            FI_FacturaPuntoEntrega                   FP	(NOLOCK)
            JOIN
                CO_PuntosdeEntrega                   PE	(NOLOCK)
                    on FP.PuntoEntregaId = Pe.PuntoEntregaID
            JOIN
                FI_Factura                           F	(NOLOCK)
                    on FP.idFactura = f.idFactura
					AND  f.IdContrato =  @idcontrato
            JOIN
                [CO_ClasificacionProductoNominacion] CP	(NOLOCK)
                    on FP.ProductoId = CP.ProductoNominacionId
			LEFT	JOIN
                AP_USUARIO U	(NOLOCK)
                    on FP.CREADOPOR = U.UsuarioID
        Where
            f.IdContrato =  @idcontrato
        order by
            FP.idfacturaPuntoEntrega desc
    END
