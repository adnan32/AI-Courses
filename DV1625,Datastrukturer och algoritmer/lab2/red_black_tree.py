"""This cod writtin by Adnan Altukleh"""
import sys
class Node(object):
    """creating a nod"""
    def __init__(self, val):
        self._parent = None
        self._left = None
        self._right = None
        self._color = "Red"
        self._item = val
    """geting a color"""
    @property
    def color(self):
        return self._color
    """geting a value fo a nod"""
    @property
    def item(self):
        return self._item
    """geting a left chaild"""
    @property
    def left(self):
        return self._left
    """geting a right chaild"""
    @property
    def right(self):
        return self._right
    """geting a parent"""
    @property
    def parent(self):
        return self._parent
    """set a new value"""
    @item.setter
    def item(self,val):
        self._item=val
    """set a new color"""
    @color.setter
    def color(self,val):
        self._color=val
    """set a new left chaild"""
    @left.setter
    def left(self,val):
        self._left=val
    """set a new right chaild"""
    @right.setter
    def right(self,val):
        self._right=val
    """set a new parent"""
    @parent.setter
    def parent(self,val):
        self._parent=val
class RedBlackTree():
    '''Creating red black tree'''
    def __init__(self):
        self._nil = Node(None)
        self._nil.color="Black"
        self._root = self._nil
    def insert(self, value):
        """Inserting elements to tree"""
        if self.search(value):
            print("value already exist in tree")
        else:
            node = Node(value)
            node.left=self._nil
            node.right=self._nil
            nod1 = self._nil
            nod2 = self._root
            while nod2 != self._nil:
                nod1 = nod2
                if node.item < nod2.item:
                    nod2 = nod2.left
                else:
                    nod2 = nod2.right
            node.parent=nod1
            if nod1 == self._nil:
                self._root = node
            elif node.item < nod1.item:
                nod1.left=node
            else:
                nod1.right=node
            if node.parent == self._nil:
                node.color="Black"
                return
            if node.parent.parent == self._nil:
                return
            self._insert_fix(node)
    def _insert_fix(self, node):
        """help method for insert"""
        while node.parent.color == "Red":
            if node.parent == node.parent.parent.left:
                unc = node.parent.parent.right
                if unc.color == "Red":
                    unc.color="Black"
                    node.parent.color="Black"
                    node.parent.parent.color="Red"
                    node = node.parent.parent
                else:
                    if node == node.parent.right:
                        node = node.parent
                        self._left_rotate(node)
                    node.parent.color="Black"
                    node.parent.parent.color="Red"
                    self._right_rotate(node.parent.parent)
            else:
                unc = node.parent.parent.left
                if unc.color == "Red":
                    unc.color="Black"
                    node.parent.color="Black"
                    node.parent.parent.color="Red"
                    node = node.parent.parent
                else:
                    if node == node.parent.left:
                        node = node.parent
                        self._right_rotate(node)
                    node.parent.color="Black"
                    node.parent.parent.color="Red"
                    self._left_rotate(node.parent.parent)
            if node.item == self._root.item:
                break
        self._root.color="Black"
    def _left_rotate(self, node):
        """Left rotating nod in tree"""
        nod1 = node.right
        node.right=nod1.left
        if nod1.left != self._nil:
            nod1.left.parent=node
        nod1.parent=node.parent
        if node.parent == self._nil:
            self._root = nod1
        elif node == node.parent.left:
            node.parent.left=nod1
        else:
            node.parent.right=nod1
        nod1.left=node
        node.parent=nod1
    def _right_rotate(self, node):
        """Right rotating nod in tree"""
        nod1 = node.left
        node.left=nod1.right
        if nod1.right != self._nil:
            nod1.right.parent=node
        nod1.parent=node.parent
        if node.parent == self._nil:
            self._root = nod1
        elif node == node.parent.right:
            node.parent.right=nod1
        else:
            node.parent.left=nod1
        nod1.right=node
        node.parent=nod1
    def search(self, value):
        """Searching after nod in tree if existed"""
        return self._search_helper(self._root, value).item == value
    def _search_helper(self, node, value):
        """Help method for search method"""
        if value == node.item:
            return node
        elif node.item == self._nil.item:
            return node
        elif value < node.item:
            return self._search_helper(node.left, value)
        else:
            return self._search_helper(node.right, value)
    def max(self):
        """Looking after the highist element in tree"""
        return self._max_helper(self._root).item
    def _max_helper(self, max_value):
        if max_value.right.item == None:
            return max_value
        else:
            return self._max_helper(max_value.right)
    def min(self):
        """Looking after the lowest element in tree"""
        return self._min_helper(self._root).item
    def _min_helper(self, min_value):
        if min_value.left.item == None:
            return min_value
        else:
            return self._min_helper(min_value.left)
    def path(self, value):
        """Giving the path for an element in tree"""
        nod2 = []
        return self._path_helper(self._root, value, nod2)
    def _path_helper(self, node, value, nod2):
        nod2.append(node.item)
        if value == node.item:
            return nod2
        elif node.item == self._nil.item:
            return " Obs! wanted value is not in tree"
        elif value < node.item:
            return self._path_helper(node.left, value, nod2)
        else:
            return self._path_helper(node.right, value, nod2)
    def remove(self, value):
        """Removing an element from tree"""
        node_to_remove = self._search_helper(self._root, value)
        if node_to_remove.item is not None:
           self._remove_helper(node_to_remove)
        else:
            return
    def _remove_helper(self, zeos):
        nod1 = zeos
        y_original_color = nod1.color
        if zeos.left.item == self._nil.item:
            nod2 = zeos.right
            self._transplant(zeos, zeos.right)
        elif zeos.right.item == self._nil.item:
            nod2 = zeos.left
            self._transplant(zeos, zeos.left)
        else:
            nod1 = self._min_helper(zeos.right)
            y_original_color = nod1.color
            nod2 = nod1.right
            if nod1.parent.item == zeos.item:
                nod2.parent=nod1
            else:
                self._transplant(nod1, nod1.right)
                nod1.right=zeos.right
                nod1.right.parent=nod1
            self._transplant(zeos, nod1)
            nod1.left=zeos.left
            nod1.left.parent=nod1
            nod1.color=zeos.color
        if y_original_color == "Black":
            self._remove_fixer(nod2)
    def _transplant(self, ultr, veg):
        if ultr.parent == self._nil:
            self._root = veg
        elif ultr == ultr.parent.left:
            ultr.parent.left=veg
        else:
            ultr.parent.right=veg
        veg.parent=ultr.parent
    def _remove_fixer(self, nod2):
        while nod2.item != self._root.item and nod2.color == "Black":
            if nod2 == nod2.parent.left:
                saba = nod2.parent.right
                if saba.color == "Red":
                    saba.color="Black"
                    nod2.parent.color="Red"
                    self._left_rotate(nod2.parent)
                    saba = nod2.parent.right
                if saba.left != None:
                    if saba.left.color == "Black" and saba.right.color == "Black":
                        saba.color="Red"
                        nod2 = nod2.parent
                    else:
                        if saba.right.color == "Black":
                            saba.left.color="Black"
                            saba.color="Red"
                            self._right_rotate(saba)
                            saba = nod2.parent.right
                        saba.color=nod2.parent.color
                        nod2.parent.color="Black"
                        saba.right.color="Black"
                        self._left_rotate(nod2.parent)
                        nod2 = self._root
                else:
                    break
            else:
                saba = nod2.parent.left
                if saba.color == "Red":
                    saba.color="Black"
                    nod2.parent.color="Red"
                    self._right_rotate(nod2.parent)
                    saba = nod2.parent.left
                if saba.right != None:
                    if saba.right.color == "Black" and saba.left.color == "Black":
                        saba.color="Red"
                        nod2 = nod2.parent
                    else:
                        if saba.left.color == "Black":
                            saba.right.color="Black"
                            saba.color="Red"
                            self._left_rotate(saba)
                            saba = nod2.parent.left
                        saba.color=nod2.parent.color
                        nod2.parent.color="Black"
                        saba.left.color="Black"
                        self._right_rotate(nod2.parent)
                        nod2 = self._root
                else:
                    break
        nod2.color="Black"
    def bfs(self):
        """Breadth first"""
        node = self._root
        data = []
        queue = []
        queue.append(node)
        self._bfs_h(queue, data)
        que_ue = []
        for nod2 in data:
            if nod2.item is not None:
                que_ue.append([nod2.item, nod2.color,
                 nod2.left.item, nod2.right.item])
        return que_ue
    def _bfs_h(self, queue, data):
        while len(queue)!= 0:
            node = queue.pop(0)
            data.append(node)
            if node.left:
                queue.append(node.left)
            if node.right:
                queue.append(node.right)