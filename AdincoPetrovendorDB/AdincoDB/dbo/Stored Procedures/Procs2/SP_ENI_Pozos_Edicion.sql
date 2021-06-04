USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_ENI_Pozos_Edicion]    Script Date: 04/06/2021 01:30:52 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 02-06-2021
-- Description:	consulta de pozos para eni
-- =============================================
CREATE PROCEDURE [dbo].[SP_ENI_Pozos_Edicion] 
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here

		 SELECT 
			I.IdInstalacion,
			I.NombreInstalacion
		 FROM dbo.CO_Instalacion I
              JOIN dbo.CO_ActividadCIEP A ON I.IdActividad = A.IdActividad
              JOIN dbo.CO_AreaContractual AC ON I.IdAreaContractual = AC.IdAreaContractual
              JOIN dbo.CO_Contrato C ON AC.IdAreaContractual = C.IdAreaContractual
         WHERE C.IdContrato = @IdContrato
               AND A.IdActividad = 5;

     END; 