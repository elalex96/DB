-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_PV_AltaSubcontratista] 
--
@RFC         NVARCHAR(MAX), 
@RazonSocial NVARCHAR(MAX), 
@UsuarioID   INT
--
AS
BEGIN
         SET NOCOUNT ON

         DECLARE @RepresentanteLegal NVARCHAR(MAX)= '', 
		 @DiasCreditoID INT= 0, 
		 @Giro NVARCHAR(MAX)= '', 
		 @PatronalIMSS NVARCHAR(MAX)= '', 
		 @TipoPersonaFiscalID INT= 1, 
		 @NacionalidadID INT= 1, 
		 @ClasificacionID INT= 1, 
		 @Capital NVARCHAR(MAX)= 0, 
		 @IdStatusValidacion INT= 0, 
		 @MotivoRechazo NVARCHAR(MAX)= '', 
		 @NombreComercial NVARCHAR(MAX), 
		@CURP NVARCHAR(MAX)= '', 
		@FormaPagoID INT= 0, 
		@GrupoCuentasID INT= 0,
		@ID INT

         SET @NombreComercial = @RazonSocial

IF 0 = (SELECT COUNT(1) FROM PV_Subcontratista WHERE RFC = @RFC)
BEGIN
         INSERT INTO [dbo].[PV_Subcontratista]
         ([RFC], 
          [RazonSocial], 
          [RepresentanteLegal], 
          [DiasCreditoID], 
          [Giro], 
          [PatronalIMSS], 
          [TipoPersonaFiscalID], 
          [NacionalidadID], 
          [ClasificacionID], 
          [Capital], 
          [IdStatusValidacion], 
          [MotivoRechazo], 
          [NombreComercial], 
          [CURP], 
          [FormaPagoID], 
          [GrupoCuentasID], 
          [UsuarioID], 
          [IsActivo], 
          [IsEliminado]
         )
         VALUES
         (@RFC, 
          @RazonSocial, 
          @RepresentanteLegal, 
          @DiasCreditoID, 
          @Giro, 
          @PatronalIMSS, 
          @TipoPersonaFiscalID, 
          @NacionalidadID, 
          @ClasificacionID, 
          @Capital, 
          @IdStatusValidacion, 
          @MotivoRechazo, 
          @NombreComercial, 
          @CURP, 
          @FormaPagoID, 
          @GrupoCuentasID, 
          @UsuarioID, 
          1, 
          0
         );
         SELECT @@IDENTITY AS ID, 
                concat('El proveedor se ha actualizado exitosamente con el id ', @@IDENTITY) AS MSG
END
ELSE
BEGIN
	UPDATE	PV_Subcontratista
		SET
			IsActivo = 1,
			IsEliminado = 0,
			RazonSocial	=	@RazonSocial,
			UsuarioID	=	@UsuarioID,
			NombreComercial	=	@NombreComercial
	WHERE
		RFC = @RFC

	SELECT @ID = IdSubcontratista
	FROM PV_Subcontratista
	WHERE RFC = @RFC

	SELECT @ID AS ID,
	concat('El proveedor se ha actualizado exitosamente con el id ', @ID) AS MSG
END

END;

