USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_ActualizarFirmaTarea'
)
DROP PROCEDURE SP_MM_ActualizarFirmaTarea;
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_ActualizarFirmaTareaPedido]    Script Date: 26/08/2022 12:34:28 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel AC
-- Create date: 26-08-2022
-- Description:	 Se actualiza información de la firma de la tarea  
-- =============================================
CREATE procedure [dbo].[SP_MM_ActualizarFirmaTarea]
	@IdTarea INT,
	@Firma NVARCHAR(MAX) 
AS
BEGIN
	
	UPDATE TA_Tarea
	SET IdFirma=@Firma 
	WHERE IdTarea=@IdTarea	

END