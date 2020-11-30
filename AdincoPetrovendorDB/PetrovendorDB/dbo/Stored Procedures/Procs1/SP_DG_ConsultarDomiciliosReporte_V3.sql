-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DG_ConsultarDomiciliosReporte_V3] @IdProveedor INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SELECT IdDomicilio,
           tipoDom.TipoDomicilio AS TipoDomicilio,
           CONCAT(
                     CASE
                         WHEN D.Calle IS NULL THEN
                             ''
                         ELSE
                             'Calle ' + D.Calle
                     END,
                     CASE
                         WHEN D.NoExterior IS NULL THEN
                             ''
                         ELSE
                             ' No Ext ' + D.NoExterior
                     END,
                     CASE
                         WHEN D.NoInterior IS NULL THEN
                             ''
                         ELSE
                             ' No Int ' + D.NoInterior
                     END,
                     ' Colonia ',
                     D.Colonia,
                     ' ,',
                     D.Municipio,
                     ' ,',
                     D.Estado,
                     ' ,',
                     PR.Pais,
                     ' CP ',
                     D.CodigoPostal,
                     CASE
                         WHEN D.TipoViabilidad IS NULL THEN
                             ''
                         ELSE
                             ' Tipo Viabilidad ' + D.TipoViabilidad
                     END,
                     CASE
                         WHEN D.NombreViabilidad IS NULL THEN
                             ''
                         ELSE
                             ' Nombre Viabilidad ' + D.NombreViabilidad
                     END
                 ) AS domicilio
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
