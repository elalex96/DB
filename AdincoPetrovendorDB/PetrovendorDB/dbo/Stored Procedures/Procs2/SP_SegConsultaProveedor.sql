-- =============================================
-- Author:		Manuel Cruz
-- Create date: 25-01-17
-- Description:	
-- =============================================
-- =============================================
-- Author:		Pedro Acuña
-- Modified date: 23/Ago/2017
-- Description: Se agregan los campos Giro, imss, monedafacturar, telefono, curp, rppc	
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Modified date: 29/Ago/2017
-- Description: Modifique condición de IsEliminado a is null	
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Modified date: 03/01/2018
-- Description: Cambie retorno de imagen nvarchar a image 
-- =============================================
CREATE PROCEDURE [dbo].[SP_SegConsultaProveedor] 
	-- Add the parameters for the stored procedure here
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT P.IdProveedor, N.Nacionalidad, P.RFC, TP.IdTipoRegimen, P.RazonSocial, 
	P.RegimenCapital, P.FechaConstitucion, P.FechaOperacion, P.SituacionContribuyente, 
	P.FechaCambioSituacion, P.Alias, P.Entidad, P.Municipio, P.Colonia, P.TipoVialidad, 
	P.NombreVialidad, P.NumExterior, P.NumInterior, P.CodigoPostal, IP.ImagenProveedor,TP.TipoRegimen,
	p.Giro,p.IMSS,P.MonedaFacturar,P.Telefono,p.CURP,p.RPPC, p.IdNacionalidad, p.AnteriorInhabilitadoSFP, 
	p.InhabilitadoSFP, p.FechaFinalizacionSancionSFP, p.IdRegimenCapital
	FROM S_UsuarioProveedor UP
	JOIN S_Proveedor P ON UP.IdProveedor = P.IdProveedor
	JOIN S_Nacionalidad N ON P.IdNacionalidad = N.IdNacionalidad
	JOIN S_TipoRegimen TP ON P.IdTipoRegimen = TP.IdTipoRegimen
	LEFT JOIN S_ImagenPerfil IP ON IP.IdProveedor = P.IdProveedor 
	WHERE UP.IdUsuario = @IdUsuario AND (IsEliminado = 0 OR IsEliminado IS NULL)

END


