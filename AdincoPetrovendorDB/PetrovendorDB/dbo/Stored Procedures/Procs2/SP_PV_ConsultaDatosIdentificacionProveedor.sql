-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultaDatosIdentificacionProveedor]
    -- Add the parameters for the stored procedure here
    @Idproveedor INT,
	@IdContrato INT, 
	@IdUsuario INT, 
	@fchRegistro DATETIME
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SELECT p.IdProveedor,
           n.Nacionalidad,
           p.RFC,
           tipoRe.TipoRegimen,
           p.RazonSocial,
           CASE
               WHEN regCapital.IdRegimenCapital = 5 THEN
                   'No Aplica'
               ELSE
                   regCapital.Regimen
           END AS Regimen,
           p.FechaConstitucion,
           p.SituacionContribuyente,
           p.FechaCambioSituacion,
           SUBSTRING(
           (
               SELECT ', ' + RTRIM(GE.GiroProveedor) AS 'data()'
               FROM dbo.S_Proveedor p
                   LEFT JOIN dbo.PV_PerfilGiroEmpresarial AS PGE
                       ON PGE.IdProveedor = p.IdProveedor
                   LEFT JOIN dbo.PV_GiroEmpresarial AS GE
                       ON GE.IdGiroProveedor = PGE.IdGiroEmpresarial -- METODO PARA CONCATENAR LOS GIROS EMPRESARIALES POR PROVEEDOR
               WHERE p.IdProveedor = @idproveedor AND PGE.Activo = 1
               FOR XML PATH('')
           ),
           2,
           9999
                    ) AS giros,
           p.IMSS,
           tipoMoneda.TipoMoneda,
           p.Telefono,
           p.CURP,
           p.RPPC
    FROM dbo.S_Proveedor p
        LEFT JOIN S_Nacionalidad n
            ON p.IdNacionalidad = n.IdNacionalidad
        LEFT JOIN dbo.PV_ClasificacionEmpresaProveedor AS CEP
            ON CEP.IdProveedor = p.IdProveedor
        LEFT JOIN dbo.PV_ClasificacionPyMES AS CPY
            ON CPY.IdClasificacion = CEP.IdClasificacionEmpresa
        LEFT JOIN dbo.S_TipoRegimen tipoRe
            ON tipoRe.IdTipoRegimen = p.IdTipoRegimen
        LEFT JOIN dbo.PV_TipoMoneda tipoMoneda
            ON tipoMoneda.IdMoneda = p.MonedaFacturar
        LEFT JOIN dbo.RegimenCapital regCapital
            ON regCapital.IdRegimenCapital = p.IdRegimenCapital
    WHERE p.IdProveedor = @idproveedor
END



