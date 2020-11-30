-- =============================================
-- Author:	Reyna Olvera
-- Create date: 12/01/2018
-- Description:	Cambia visibilidad de estatus menu
-- =============================================
CREATE PROCEDURE AP_AdministracionMenuRol
	-- Add the parameters for the stored procedure here
	@MenuPorIds  varchar(300),
	@idRol int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
Declare  @cont int,
 @cantIdRM int;

 set @cont =1;
update ap_MenuporRol
set visible =0
where idRol=@idRol;

IF OBJECT_ID('tempdb..#idMenuRolesT') IS NOT NULL
DROP TABLE #idMenuRolesT
CREATE TABLE #idMenuRolesT( id INT primary key identity(1,1) , idMenuRol int);


insert into #idMenuRolesT(idMenuRol)
	select splitdata as idMenuRol
	from [dbo].[fnSplitString](@MenuPorIds, ',')
	
Select	@cantIdRM= count(id) from #idMenuRolesT;

while(@cont<=@cantIdRM)
begin 

update ap_MenuporRol
set visible =1
where 
idMenuRol=(Select idMenuRol from #idMenuRolesT where id=@cont) and
 idRol=@idRol

set @cont=@cont+1;
end


END

