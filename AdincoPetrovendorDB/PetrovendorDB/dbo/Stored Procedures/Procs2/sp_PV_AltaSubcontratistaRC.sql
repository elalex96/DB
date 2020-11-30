-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_PV_AltaSubcontratistaRC] 
	-- Add the parameters for the stored procedure here
	
	@RFC	nvarchar(MAX) ,
	@RazonSocial	nvarchar(MAX) ,
	--@RepresentanteLegal	nvarchar(MAX) ,
	--@DiasCreditoID	int ,
	--@Giro	nvarchar(MAX) ,
	--@PatronalIMSS	nvarchar(MAX) ,
	--@TipoPersonaFiscalID	int ,
	@RegimenCapital nvarchar(MAX),
	@NacionalidadID	int ,
	--@ClasificacionID	int ,
	--@Capital	nvarchar(MAX) ,
	--@IdStatusValidacion	int ,
	--@MotivoRechazo	nvarchar(MAX) ,
	@NombreComercial	nvarchar(MAX) 
	--@CURP	nvarchar(MAX) ,
	--@FormaPagoID	int ,
	--@GrupoCuentasID	int ,
	--@UsuarioID	int --,

--@Entidad	nvarchar(MAX) ,
--@Municipio	nvarchar(MAX) ,
---@Colonia	nvarchar(MAX) ,
--@NombreVialidad	nvarchar(MAX) ,
--@NumExterior	nvarchar(MAX) ,
--@NumInterior	nvarchar(MAX) ,
--@CodigoPostal	nvarchar(MAX) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here


--INSERT INTO [dbo].[PV_Subcontratista]
--           ([RFC]
--           ,[RazonSocial]
--           ,[RepresentanteLegal]
--           ,[DiasCreditoID]
--           ,[Giro]
--           ,[PatronalIMSS]
--           ,[TipoPersonaFiscalID]
--           ,[NacionalidadID]
--           ,[ClasificacionID]
--           ,[Capital]
--           ,[IdStatusValidacion]
--           ,[MotivoRechazo]
--           ,[NombreComercial]
--           ,[CURP]
--           ,[FormaPagoID]
--           ,[GrupoCuentasID]
--           ,[UsuarioID]
--           ,[Entidad]
--           ,[Municipio]
--           ,[Colonia]
--           ,[NombreVialidad]
--           ,[NumExterior]
--           ,[NumInterior]
--           ,[CodigoPostal]
--           ,[IsEliminado])
--     VALUES
--           (
--			@RFC,
--			@RazonSocial,
--			@RepresentanteLegal,
--			@DiasCreditoID,
--			@Giro,
--			@PatronalIMSS,
--			@TipoPersonaFiscalID,
--			@NacionalidadID,
--			@ClasificacionID,
--			@Capital,
--			@IdStatusValidacion,
--			@MotivoRechazo,
--			@NombreComercial,
--			@CURP,
--			@FormaPagoID,
--			@GrupoCuentasID,
--			@UsuarioID,
--@Entidad,
--@Municipio,
--@Colonia,
--@NombreVialidad,
--@NumExterior,
--@NumInterior,
--@CodigoPostal,
--0)

INSERT INTO [dbo].[S_Proveedor]
           ([RFC]
           ,[RazonSocial]
		   ,[RegimenCapital]
           --,[RepresentanteLegal]
           --,[DiasCreditoID]
           --,[Giro]
           --,[PatronalIMSS]
           --,[TipoPersonaFiscalID]
           ,[IdNacionalidad]
           --,[ClasificacionID]
           --,[Capital]
           --,[IdStatusValidacion]
           --,[MotivoRechazo]
           ,[Alias]
           --,[CURP]
           --,[FormaPagoID]
           --,[GrupoCuentasID]
           --,[UsuarioID]
)
     VALUES
           (
			@RFC,
			@RazonSocial,
			@RegimenCapital,
			--@RepresentanteLegal,
			--@DiasCreditoID,
			--@Giro,
			--@PatronalIMSS,
			--@TipoPersonaFiscalID,
			--@NacionalidadID,
			--@ClasificacionID,
			--@Capital,
			--@IdStatusValidacion,
			@NacionalidadID,
			--@MotivoRechazo,
			@NombreComercial)
			--@CURP,
			--@FormaPagoID,
			--@GrupoCuentasID,
			--@UsuarioID)
SELECT @@IDENTITY  AS ID , concat('El proveedor se ha actualizado exitosamente con el id ' , @@IDENTITY)  as MSG


END

