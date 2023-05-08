-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_InsertarEquipo]
@ip varchar(50),
@soEquipo varchar(50),
@ubicacion varchar(200),
@nombreEquipo varchar(50)
AS
BEGIN
insert into AP_Equipo values(@ip,@soequipo,@ubicacion,@nombreEquipo);
END


