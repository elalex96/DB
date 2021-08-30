USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_DEAUsuarios]    Script Date: 26/08/2021 12:42:33 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 25/08/2021
-- Description:	Devuelve los proveedores para registrar descripción SAP
-- =============================================
CREATE PROCEDURE SP_DEAProveedoresDescripcionRegistraSAP
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdUsuario INT,
@IdProveedorRelacionar INT,
@DescripcionSAP NVARCHAR(MAX)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IdContratista INT, @IdProveedorDescripcionSAP INT
	--
	SET @IdContratista = 
	(SELECT DISTINCT IdContratista
	FROM [S_UsuarioProveedor] UP
	JOIN Adinco.dbo.CO_Contrato C ON UP.idContrato = C.IdContrato
	WHERE UP.IdProveedor = @IdProveedor)
	--
	 INSERT INTO [dbo].[DEA_ProveedorDescripcionSAP]
           (
           [IdProveedor],
           [DescripcionSAP],
           [CreadoEn],
           [CreadoPor],
           [IdContratista],
           [IsEliminado]
           )
     VALUES
           (
           @IdProveedorRelacionar,
           @DescripcionSAP,
           GETDATE(),
           @IdUsuario,
           @IdContratista,
           0
		   )

         SET @IdProveedorDescripcionSAP = @@IDENTITY;
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj, 
                @IdProveedorDescripcionSAP  AS ID;
END
GO