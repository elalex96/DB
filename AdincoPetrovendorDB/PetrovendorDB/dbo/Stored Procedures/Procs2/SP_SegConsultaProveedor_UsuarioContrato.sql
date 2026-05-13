-- =============================================
-- Author:		Josue Glez
-- Create date: 29-12-17
-- Description:	Consulta detalle del proveedor de la operadora de acuerdo al contrato
-- =============================================
-- ============================================= 
-- Modified: Daniel AC
-- Updated date: 13/02/18
-- Description: Actualice parametros nuevos que se agregaron en SP SP_SegConsultaProveedor
-- =============================================

CREATE PROCEDURE [dbo].[SP_SegConsultaProveedor_UsuarioContrato] --2205,3
	-- Add the parameters for the stored procedure here
	@IdUsuario INT, @IdContrato INT
AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON ;

		SELECT	P.IdProveedor , N.Nacionalidad, 
				P.RFC, TP.IdTipoRegimen, P.RazonSocial, P.RegimenCapital, P.FechaConstitucion, P.FechaOperacion ,
				P.SituacionContribuyente, P.FechaCambioSituacion, P.Alias, P.Entidad, P.Municipio, P.Colonia ,
				P.TipoVialidad, P.NombreVialidad, P.NumExterior, P.NumInterior, P.CodigoPostal, IP.ImagenProveedor ,
				TP.TipoRegimen, p.Giro, p.IMSS, P.MonedaFacturar, P.Telefono, p.CURP, p.RPPC, p.IdNacionalidad ,
				p.AnteriorInhabilitadoSFP, p.InhabilitadoSFP, p.FechaFinalizacionSancionSFP, p.IdRegimenCapital ,
				P.IdTipoRegimen
		  FROM	S_UsuarioProveedor UP
				JOIN S_Proveedor P
					 ON UP.IdProveedor = P.IdProveedor
				LEFT JOIN S_Nacionalidad N
					 ON P.IdNacionalidad = N.IdNacionalidad
				LEFT JOIN S_TipoRegimen TP
						  ON P.IdTipoRegimen = TP.IdTipoRegimen
				LEFT JOIN S_ImagenPerfil IP
						  ON IP.IdProveedor = P.IdProveedor
		 WHERE
				UP.IdUsuario = @IdUsuario
				AND UP.idContrato = @IdContrato
				AND (	IsEliminado = 0
						OR	IsEliminado IS NULL )
	END