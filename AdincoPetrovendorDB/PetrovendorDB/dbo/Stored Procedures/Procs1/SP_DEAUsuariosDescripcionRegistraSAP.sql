-- =============================================
-- Author:		Manuel Cruz
-- Create date: 25/08/2021
-- Description:	Devuelve los proveedores para registrar descripción SAP
-- =============================================
CREATE PROCEDURE SP_DEAUsuariosDescripcionRegistraSAP
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdUsuario INT,
@IdUsuarioRelacionar INT,
@DescripcionSAP NVARCHAR(MAX)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IdContratista INT, @IdUsuarioSolicitanteSAP INT
	--
	SET @IdContratista = 
	(SELECT DISTINCT IdContratista
	FROM [S_UsuarioProveedor] UP
	JOIN Adinco.dbo.CO_Contrato C ON UP.idContrato = C.IdContrato
	WHERE UP.IdProveedor = @IdProveedor)
	--
	 INSERT INTO [dbo].[DEA_UsuarioSolicitanteSAP]
           (
		   [IdUsuario],
           [DescripcionSAP],
           [CreadoEn],
           [CreadoPor],
           [IdContratista],
           [IsEliminado]
		   )
     VALUES
           (
           @IdUsuarioRelacionar,
           @DescripcionSAP,
           GETDATE(),
           @IdUsuario,
           @IdContratista,
           0
		   )

         SET @IdUsuarioSolicitanteSAP = @@IDENTITY;
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj, 
                @IdUsuarioSolicitanteSAP AS ID;
END
