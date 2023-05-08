-- =============================================
-- Author:		Daniel Cruz
-- Create date: 22/01/2018
-- Description:	Consultar tipos de domicilios 
-- =============================================
CREATE PROCEDURE [dbo].[SP_DG_Tipodomiclios] 
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdUsuario INT, 
@IdContrato INT, 
@FechaRegistro DATETIME

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		
    -- Insert statements for procedure here
          
		  ---Validación de Estatus de documentos
		 SELECT [IdTipoDomicilio], [TipoDomicilio] FROM [DG_TipoDomicilio] WHERE [ACTIVO] = 1  ORDER BY [TipoDomicilio] 

		     
     END; 
