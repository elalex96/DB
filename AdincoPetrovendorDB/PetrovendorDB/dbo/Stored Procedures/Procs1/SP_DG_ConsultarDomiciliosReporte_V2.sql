-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DG_ConsultarDomiciliosReporte_V2] @IdProveedor INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SELECT IdDomicilio,
           tipoDom.TipoDomicilio AS TipoDomicilio,
           D.Calle,
           D.NoExterior,
           D.NoInterior,
           D.Colonia,
           D.Municipio,
           D.Estado,
           PR.Pais,
           D.CodigoPostal,
           D.TipoViabilidad,
           D.NombreViabilidad
    FROM [dbo].[DG_Domicilio] AS D
        INNER JOIN [dbo].[DG_TipoDomicilio] AS TD
            ON TD.IdTipoDomicilio = D.IdTipoDomicilio
        INNER JOIN [dbo].[PV_PaisRepublica] AS PR
            ON D.IdPais = PR.id
        INNER JOIN [dbo].[S_Proveedor] AS P
            ON P.IdProveedor = D.IdProveedor
        LEFT JOIN dbo.DG_TipoDomicilio tipoDom
            ON tipoDom.IdTipoDomicilio = D.IdTipoDomicilio
    WHERE P.IdProveedor = @IdProveedor
          AND D.Activo = 1
    ORDER BY D.IdTipoDomicilio

END
